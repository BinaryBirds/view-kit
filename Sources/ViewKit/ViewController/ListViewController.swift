//
//  ListViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//


public protocol ListViewController: ViewController {
    /// the name of the list view template
    var listView: String { get }
    /// url query parameter list order key
    var listOrderKey: String { get }
    /// url query parameter list sort key
    var listSortKey: String { get }
    /// url query parameter list search key
    var listSearchKey: String { get }
    /// url query parameter list limit key
    var listLimitKey: String { get }
    /// url query parameter list page key
    var listPageKey: String { get }

    /// returns allowed order by fields if empty list can't be ordered
    var listAllowedOrders: [FieldKey] { get }
    /// default sort direction
    var listDefaultSort: Sort { get }
    /// default list limit
    var listDefaultLimit: Int { get }

    /// builds the query in order to list objects in the admin interface
    func beforeList(req: Request, queryBuilder: QueryBuilder<Model>) throws -> QueryBuilder<Model>
    
    /// implement this method if you want to alter the sort or order function for a given field (e.g order by a joined field)
    func beforeList(req: Request, order: FieldKey, sort: Sort, queryBuilder qb: QueryBuilder<Model>) -> QueryBuilder<Model>

    /// this method is used before a page object gets rendered, you can alter the returned LeafData as needed
    func beforeListRender(page: Page<Model>) -> LeafData
 
    /// search
    func search(using: QueryBuilder<Model>, for: String)
    
    /// renders the list view
    func listView(req: Request) throws -> EventLoopFuture<View>

    /// setup list related routes
    func setupListRoute(on: RoutesBuilder)
}

public extension ListViewController {

    var listOrderKey: String { "order" }
    var listSortKey: String { "sort" }
    var listSearchKey: String { "search" }
    var listLimitKey: String { "limit" }
    var listPageKey: String { "page" }

    var listAllowedOrders: [FieldKey] { [] }
    var listDefaultSort: Sort { .asc }
    var listDefaultLimit: Int { 10 }
    
    func search(using qb: QueryBuilder<Model>, for searchTerm: String) {}

    func beforeList(req: Request, queryBuilder: QueryBuilder<Model>) throws -> QueryBuilder<Model> {
        queryBuilder
    }

    func beforeList(req: Request, order: FieldKey, sort: Sort, queryBuilder qb: QueryBuilder<Model>) -> QueryBuilder<Model> {
        qb.sort(order, sort.direction)
    }

    func beforeListRender(page: Page<Model>) -> LeafData {
        page.leafData
    }

    func listView(req: Request) throws -> EventLoopFuture<View> {
        /// first we need a QueryBuilder instance, we apply the beforeList method on the default query
        var qb = try beforeList(req: req, queryBuilder: Model.query(on: req.db))
                
        /// next we get the sort from the query, if there was no sort key we use the default sort
        var sort = listDefaultSort
        if let sortQuery: String = req.query[listSortKey], let sortValue = Sort(rawValue: sortQuery) {
            sort = sortValue
        }
        /// if custom ordering is allowed
        if !listAllowedOrders.isEmpty {
            /// we check for a new order using the query, otherwise we use the first element of the allowed orders
            let orderValue: String = req.query[listOrderKey] ?? listAllowedOrders[0].description
            let order = FieldKey(stringLiteral: orderValue)
            /// only allow ordering if the order value is in the allowed orders array
            if listAllowedOrders.contains(order) {
                qb = beforeList(req: req, order: order, sort: sort, queryBuilder: qb)
            }
        }

        /// check if there is a non-empty search term and apply the search term using the custom search method
        if let searchTerm: String = req.query[listSearchKey], !searchTerm.isEmpty {
            qb = qb.group(.or) { search(using: $0, for: searchTerm) }
        }

        /// apply the limit and page properties
        let limit: Int = req.query[listLimitKey] ?? listDefaultLimit
        let page: Int = max((req.query[listPageKey] ?? 1), 1)
        
        /// calculate the start and end position
        let start: Int = (page - 1) * limit
        let end: Int = page * limit
        
        /// count the total number of elements for the page info
        let count = qb.count()
        /// set the range filter and request all the elements in the given range
        let items = qb.copy().range(start..<end).all()
        
        ///query both the total count and the models for the requested page
        return items.and(count).map { (models, total) -> Page<Model> in
            let totalPages = Int(ceil(Float(total) / Float(limit)))
            return Page(models, info: .init(current: page, limit: limit, total: totalPages))
        }
        /// map the page elements to Leaf values & render the list view
        .map { beforeListRender(page: $0) }
        .flatMap { req.leaf.render(template: listView, context: ["list": $0]) }
    }

    func setupListRoute(on builder: RoutesBuilder) {
        builder.get(use: listView)
    }
}
