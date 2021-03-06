import Result

struct CommentParser: DataParser {
    typealias ParsedObject = PersistedComment

    func parse(json: AnyObject) -> Result<PersistedComment, ParseError> {
        guard
            let id = json["id"] as? Int,
            let text = json["comment"] as? String,
            let createdDateString = json["created_at"] as? String,
            let createdDate = DateConverter.formattedDateFromString(createdDateString),
            let restaurantId = json["restaurant_id"] as? Int,
            let userJson = json["user"] as? [String: AnyObject],
            let userId = userJson["id"] as? Int,
            let userName = userJson["name"] as? String else
        {
            return Result.Failure(.CommentParseError)
        }

        let persistedComment = PersistedComment(
            id: id,
            text: text,
            createdDate: createdDate,
            restaurantId: restaurantId,
            userId: userId,
            userName: userName
        )

        return Result.Success(persistedComment)
    }
}
