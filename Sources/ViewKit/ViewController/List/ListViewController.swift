//
//  ListViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 04..
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
    var listDefaultSort: ListSort { get }
    
    /// default list limit
    var listDefaultLimit: Int { get }

    /// check if there is access to list objects, if the future the server will respond with a forbidden status
    func accessList(req: Request) -> EventLoopFuture<Bool>
    
    /// builds the query in order to list objects in the admin interface
    func beforeListQuery(req: Request, queryBuilder: QueryBuilder<Model>) -> QueryBuilder<Model>
    
    /// implement this method if you want to alter the sort or order function for a given field (e.g order by a joined field)
    func listQuery(order: FieldKey, sort: ListSort, queryBuilder: QueryBuilder<Model>, req: Request) -> QueryBuilder<Model>
    
    /// search
    func listQuery(search: String, queryBuilder: QueryBuilder<Model>, req: Request)
    
    /// this method is used before a page object gets rendered, you can alter the returned TemplateData as needed
    func beforeListPageRender(page: ListPage<Model>) -> TemplateData
    
    /// renders the list view
    func listView(req: Request) throws -> EventLoopFuture<View>
    
    /// setup list related routes
    func setupListRoute(on: RoutesBuilder)
}
