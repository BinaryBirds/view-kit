//
//  ListViewController+Public.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public extension ListViewController {

    var listOrderKey: String { "order" }
    var listSortKey: String { "sort" }
    var listSearchKey: String { "search" }
    var listLimitKey: String { "limit" }
    var listPageKey: String { "page" }

    var listAllowedOrders: [FieldKey] { [] }
    var listDefaultSort: ListSort { .asc }
    var listDefaultLimit: Int { 10 }
    
    func accessList(req: Request) -> EventLoopFuture<Bool> {
        req.eventLoop.future(true)
    }

    func beforeListQuery(req: Request, queryBuilder: QueryBuilder<Model>) -> QueryBuilder<Model> {
        queryBuilder
    }

    func listQuery(order: FieldKey, sort: ListSort, queryBuilder qb: QueryBuilder<Model>, req: Request) -> QueryBuilder<Model> {
        qb.sort(order, sort.direction)
    }
    
    func listQuery(search: String, queryBuilder qb: QueryBuilder<Model>, req: Request) {
        /// default implementation is empty
    }

    func beforeListPageRender(page: ListPage<Model>) -> LeafData {
        page.leafData
    }

    func listView(req: Request) throws -> EventLoopFuture<View> {
        accessList(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            /// first we need a QueryBuilder instance, we apply the beforeList method on the default query
            var qb = beforeListQuery(req: req, queryBuilder: Model.query(on: req.db))
                    
            /// next we get the sort from the query, if there was no sort key we use the default sort
            var sort = listDefaultSort
            if let sortQuery: String = req.query[listSortKey], let sortValue = ListSort(rawValue: sortQuery) {
                sort = sortValue
            }
            /// if custom ordering is allowed
            if !listAllowedOrders.isEmpty {
                /// we check for a new order using the query, otherwise we use the first element of the allowed orders
                let orderValue: String = req.query[listOrderKey] ?? listAllowedOrders[0].description
                let order = FieldKey(stringLiteral: orderValue)
                /// only allow ordering if the order value is in the allowed orders array
                if listAllowedOrders.contains(order) {
                    qb = listQuery(order: order, sort: sort, queryBuilder: qb, req: req)
                }
            }

            /// check if there is a non-empty search term and apply the search term using the custom search method
            if let searchTerm: String = req.query[listSearchKey], !searchTerm.isEmpty {
                qb = qb.group(.or) { listQuery(search: searchTerm, queryBuilder: $0, req: req) }
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
            return items.and(count).map { (models, total) -> ListPage<Model> in
                let totalPages = Int(ceil(Float(total) / Float(limit)))
                return ListPage(models, info: .init(current: page, limit: limit, total: totalPages))
            }
            /// map the page elements to Leaf values & render the list view
            .map { beforeListPageRender(page: $0) }
            .flatMap { render(req: req, template: listView, context: ["list": $0]) }
        }
    }

    func setupListRoute(on builder: RoutesBuilder) {
        builder.get(use: listView)
    }
}
