//
//  ListViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//


public protocol ListViewController: ViewController {
    /// the name of the list view template
    var listView: String { get }
    
    var listOrderByKey: String { get }
    var listSortKey: String { get }
    
    var listSearchKey: String { get }
    var listLimitKey: String { get }
    var listPageKey: String { get }

    var listOrderBy: [FieldKey] { get }
    var listSort: Sort { get }
    var listLimit: Int { get }

    /// builds the query in order to list objects in the admin interface
    func beforeList(req: Request, queryBuilder: QueryBuilder<Model>) throws -> QueryBuilder<Model>
 
    func search(using: QueryBuilder<Model>, for: String)
    func listView(req: Request) throws -> EventLoopFuture<View>

    func setupListRoute(on: RoutesBuilder)
}

public extension ListViewController {

    var listOrderByKey: String { "order" }
    var listSortKey: String { "sort" }

    var listSearchKey: String { "search" }
    var listLimitKey: String { "limit" }
    var listPageKey: String { "page" }

    var listOrderBy: [FieldKey] { [] }
    var listSort: Sort { .asc }
    var listLimit: Int { 10 }

    func search(using qb: QueryBuilder<Model>, for searchTerm: String) {}

    func beforeList(req: Request, queryBuilder: QueryBuilder<Model>) throws -> QueryBuilder<Model> {
        queryBuilder
    }

    func listView(req: Request) throws -> EventLoopFuture<View> {
        let customOrder: String? = req.query[listSortKey]
        var sortValue = listSort
        if let i: String = req.query[listSortKey], let o = Sort(rawValue: i) {
            sortValue = o
        }
        let searchString: String? = req.query[listSearchKey]
        let limit: Int = req.query[listLimitKey] ?? listLimit
        let page: Int = max((req.query[listPageKey] ?? 1), 1)

        var qb = try beforeList(req: req, queryBuilder: Model.query(on: req.db))
        
        if customOrder != nil || !listOrderBy.isEmpty {
            let orderValue = customOrder ?? listOrderBy[0].description
            qb = qb.sort(.init(stringLiteral: orderValue), sortValue.direction)
        }

        if let searchTerm = searchString, !searchTerm.isEmpty {
            qb = qb.group(.or) { search(using: $0, for: searchTerm) }
        }

        let start: Int = (page - 1) * limit
        let end: Int = page * limit
        
        let count = qb.count()
        let items = qb.copy().range(start..<end).all()

        return items.and(count).map { (models, total) -> Page<Model> in
            let totalPages = Int(ceil(Float(total) / Float(limit)))
            return Page(models, info: .init(current: page, limit: limit, total: totalPages))
        }
        .map { $0.map(\.leafData) }
        .flatMap {
            req.leaf.render(template: listView, context: $0.leafContext)
        }
    }

    func setupListRoute(on builder: RoutesBuilder) {
        builder.get(use: listView)
    }
}
