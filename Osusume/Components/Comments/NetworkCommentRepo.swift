import BrightFutures

struct NetworkCommentRepo <P: DataParser where P.ParsedObject == PersistedComment>: CommentRepo {
    let http: Http
    let parser: P

    func persist(comment: NewComment) -> Future<PersistedComment, RepoError> {
        let path = "/restaurants/\(comment.restaurantId)/comments"

        return http
            .post(
                path,
                headers: [:],
                parameters: ["comment": comment.text]
            )
            .mapError { _ in
                return RepoError.PostFailed
            }
            .flatMap { httpJson in
                return self.parser
                    .parse(httpJson)
                    .mapError { _ in return RepoError.ParsingFailed }
            }
    }

    func delete(commentId: Int) {
        http.delete(
            "/comments/\(commentId)",
            headers: [:],
            parameters: [:]
        )
    }
}
