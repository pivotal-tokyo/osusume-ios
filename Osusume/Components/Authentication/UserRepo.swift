import BrightFutures

protocol UserRepo {
    func login(email: String, password: String) -> Future<AuthenticatedUser, RepoError>
    func logout()
    func getMyPosts() -> Future<[Restaurant], RepoError>
    func getMyLikes() -> Future<[Restaurant], RepoError>
}
