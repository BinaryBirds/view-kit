//
//  ListViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public enum ListOrder: String, CaseIterable {
    case asc
    case desc
    
    public var sortDirection: DatabaseQuery.Sort.Direction {
        switch self {
        case .asc:
            return .ascending
        case .desc:
            return .descending
        }
    }
}

public protocol ListViewController: ViewController {
    /// the name of the list view template
    var listView: String { get }
    
    var listSortKey: String { get }
    var listOrderKey: String { get }
    var listSearchKey: String { get }
    var listLimitKey: String { get }
    var listPageKey: String { get }

    var listSortable: [FieldKey] { get }
    var listLimit: Int { get }
    var listOrder: ListOrder { get }

    /// builds the query in order to list objects in the admin interface
    func beforeList(req: Request, queryBuilder: QueryBuilder<Model>) throws -> QueryBuilder<Model>
 
    func search(using qb: QueryBuilder<Model>, for searchTerm: String)
    func listView(req: Request) throws -> EventLoopFuture<View>

    func setupListRoute(routes: RoutesBuilder)
}

public extension ListViewController {

    var listSortKey: String { "sort" }
    var listOrderKey: String { "order" }
    var listSearchKey: String { "search" }
    var listLimitKey: String { "limit" }
    var listPageKey: String { "page" }
    
    var listSortable: [FieldKey] { [] }
    var listLimit: Int { 10 }
    var listOrder: ListOrder { .asc }

    func search(using qb: QueryBuilder<Model>, for searchTerm: String) {}

    func beforeList(req: Request, queryBuilder: QueryBuilder<Model>) throws -> QueryBuilder<Model> {
        queryBuilder
    }

    func listView(req: Request) throws -> EventLoopFuture<View> {
        let sort: String? = req.query[self.listSortKey]
        var order = self.listOrder
        if let i: String = req.query[self.listOrderKey], let o = ListOrder(rawValue: i) {
            order = o
        }
        let search: String? = req.query[self.listSearchKey]
        let limit: Int = req.query[self.listLimitKey] ?? self.listLimit
        let page: Int = max((req.query[self.listPageKey] ?? 1), 1)

        var qb = try self.beforeList(req: req, queryBuilder: Model.query(on: req.db))
        
        if sort != nil || !self.listSortable.isEmpty {
            let customSort = sort ?? self.listSortable[0].description
            qb = qb.sort(.init(stringLiteral: customSort), order.sortDirection)
        }

        if let searchTerm = search, !searchTerm.isEmpty {
            qb = qb.group(.or) { self.search(using: $0, for: searchTerm) }
        }

        let start: Int = (page - 1) * limit
        let end: Int = page * limit
        
        let count = qb.count()
        let items = qb.copy().range(start..<end).all()

        return items.and(count).map { (models, total) -> PageContext<Model> in
            let totalPages = Int(ceil(Float(total) / Float(limit)))
            return PageContext(items: models, metadata: .init(page: page, limit: limit, total: totalPages))
        }
        .map { $0.map(\.viewContext) }
        .flatMap { req.view.render(self.listView, $0) }
    }

    func setupListRoute(routes: RoutesBuilder) {
        routes.get(use: self.listView)
    }
}
