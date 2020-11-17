# ViewKit

A generic, reusable view layer for building (not just) admin interfaces using Vapor 4.


## Install

Add the repository as a dependency:

```swift
.package(url: "https://github.com/binarybirds/view-kit.git", from: "1.2.0"),
```

Add ViperKit to the target dependencies:

```swift
.product(name: "ViewKit", package: "view-kit"),
```

Update the packages and you are ready.

## Basic example

Start with a regular model:

```swift
import Vapor
import Fluent
import ViewKit

final class ExampleModel: Model {

    static let schema = "examples"

    struct FieldKeys {
        static var foo: FieldKey { "foo" }
        static var bar: FieldKey { "bar" }
    }

    @ID() var id: UUID?
    @Field(key: FieldKeys.foo) var foo: String
    @Field(key: FieldKeys.bar) var bar: Int

    init() { }

    init(id: UUID? = nil, foo: String, bar: Int) {
        self.id = id
        self.foo = foo
        self.bar = bar
    }
}
```

Extend the model, so views can render it:

```swift
extension ExampleModel: LeafDataRepresentable {

    var leafData: LeafData { 
        .dictionary([
            "id": .string(id!.uuidString),
            "foo": .string(foo),
            "bar": .int(bar),
        ])
    }
}
```

Make a new template for the list, you can use [Leaf](https://github.com/vapor/leaf) or anything else.

```html
<a href="/examples/new">Create new</a>
<table>
    <thead>
        <tr>
            <th>ID</th>
            <th>Foo</th>
            <th>Bar</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
    #for(item in list):
        <tr>
            <td>#(item.id)</td>
            <td>#(item.foo)</td>
            <td>#(item.bar)</td>
            <td>
                <a href="/examples/#(item.id)">Edit</a> &middot;
                <a id="#(item.id)" href="#" onClick="confirmDelete('/examples/', this.id);">Delete</a>
            </td>
        </tr>
    #endfor
    </tbody>
</table>

<script>
function confirmDelete(path, id) {
  if (confirm("Press ok to confirm delete.")) {
     var xmlHttp = new XMLHttpRequest();
        xmlHttp.onreadystatechange = function() {
            if (xmlHttp.readyState != 4 || xmlHttp.status != 200) {
                return
            }
            console.warn(xmlHttp.responseText)
            var element = document.getElementById(id)
            var tr = element.parentElement.parentElement
            tr.parentNode.removeChild(tr)
        }
        xmlHttp.open("POST", path + id + "/delete", true);
        xmlHttp.send(null);
  }
}
</script>
```


Build a form that can handle incoming form submission requests (create + update):

```swift
import Vapor
import Fluent
import ViewKit

final class ExampleEditForm: Form {

    struct Input: Decodable {
        var id: String
        var foo: String
        var bar: String
    }

    var id: String? = nil
    var foo = StringFormField()
    var bar = StringFormField()

    init() {}

    init(req: Request) throws {
        let context = try req.content.decode(Input.self)
        if !context.id.isEmpty {
            id = context.id
        }

        foo.value = context.foo
        bar.value = context.bar
    }

    func write(to model: ExampleModel) {
        model.foo = foo.value
        model.bar = Int(bar.value)!
    }

    func read(from model: ExampleModel )  {
        id = model.id!.uuidString
        foo.value = model.foo
        bar.value = String(model.foo)
    }

    func validate(req: Request) -> EventLoopFuture<Bool> {
        var valid = true
        if Int(bar.value) == nil {
            bar.error = "Bar is not an integer"
            valid = false
        }
        return req.eventLoop.future(valid)
    }
}
```

Make a view template for the form:

```html

#if(edit.id != null):
    <h2>Edit</h2>
#else:
    <h2>Create</h2>
#endif

<form method="post" action="/examples/#if(edit.id != nil):#(edit.id)#else:new#endif" enctype="multipart/form-data">
    <input type="hidden" name="id" value="#(edit.id)">

    <section>
        <label for="foo">Foo</label>
        <input type="text" id="foo" name="foo" value="#(edit.foo.value)">
        #if(edit.foo.error != nil):
            #(edit.foo.error)
        #endif
    </section>

    <section>
        <label for="bar">Bar</label>
        <input type="text" id="bar" name="bar" value="#(edit.bar.value)">
        #if(edit.bar.error != nil):
            #(edit.bar.error)
        #endif
    </section>

    <section>
        <input type="submit" value="Save">
    </section>
</form>
```

Make a controller:

```swift
import Vapor
import Fluent
import ViewKit

final class ExampleController: AdminViewController {
    // path to the templates based on your configuration
    var listView: String = "list"
    var editView: String = "edit"

    typealias Model = ExampleModel
    typealias EditForm = ExampleEditForm
}
```

Register the routes:
```
let controller = ExampleController()
controller.setupRoutes(routes: app.routes, on: "examples")
```

Build the app and enjoy the admin interface.

## Customization

ViewKit provides lifecycle methods that you can override in the controller:

```swift
import Vapor
import Fluent
import ViewKit

final class ExampleController: AdminViewController {
    var listView: String = ""
    var editView: String = ""

    typealias Model = ExampleModel
    typealias EditForm = ExampleEditForm

    func beforeRender(req: Request, form: EditForm) -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }
    func beforeInvalidRender(req: Request, form: EditForm) -> EventLoopFuture<EditForm> {
        req.eventLoop.future(form)
    }
    func beforeList(req: Request, queryBuilder: QueryBuilder<Model>) throws -> QueryBuilder<Model> {
        queryBuilder.sort(\.$bar, .descending)
    }
    func beforeCreate(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }
    func beforeUpdate(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }
    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func afterCreate(req: Request, form: EditForm, model: Model) -> EventLoopFuture<Response> {
        req.eventLoop.future(req.redirect(to: model.viewIdentifier))
    }
    func afterUpdate(req: Request, form: EditForm, model: Model) -> EventLoopFuture<Response> {
        render(req: req, form: form).encodeResponse(for: req)
    }
}
```

ViewKit is written in a protocol oriented approach, so you can override everything else as well.

## License

[WTFPL](LICENSE) - Do what the fuck you want to.
