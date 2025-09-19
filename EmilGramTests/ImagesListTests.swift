import XCTest
@testable import EmilGram

final class ImagesListTests: XCTestCase {

    func test_willDisplayCell_doesNotCrash() {
        // given
        let viewSpy = ImagesListViewSpy()
        let presenter = ImagesListPresenter(view: viewSpy)
        presenter.photos = [
            Photo(id: "1", size: CGSize(width: 100, height: 100),
                  createdAt: Date(),
                  welcomeDescription: nil,
                  thumbImageURL: "https://example.com/thumb.jpg",
                  largeImageURL: "https://example.com/large.jpg",
                  isLiked: false)
        ]

        // when
        presenter.willDisplayCell(at: 0)

        // then
        XCTAssertTrue(true, "Метод должен отрабатывать без краша")
    }

    func test_photoAtIndex_returnsCorrectPhoto() {
        // given
        let viewSpy = ImagesListViewSpy()
        let presenter = ImagesListPresenter(view: viewSpy)
        let testPhoto = Photo(id: "1", size: CGSize(width: 100, height: 100),
                              createdAt: Date(),
                              welcomeDescription: nil,
                              thumbImageURL: "https://example.com/thumb.jpg",
                              largeImageURL: "https://example.com/large.jpg",
                              isLiked: false)
        presenter.photos = [testPhoto]

        // when
        let result = presenter.photo(at: 0)

        // then
        XCTAssertEqual(result.id, testPhoto.id)
    }

    func test_viewModel_forIndex_returnsCorrectData() {
        // given
        let viewSpy = ImagesListViewSpy()
        let presenter = ImagesListPresenter(view: viewSpy)
        let date = Date()
        presenter.photos = [
            Photo(id: "1", size: CGSize(width: 200, height: 100),
                  createdAt: date,
                  welcomeDescription: nil,
                  thumbImageURL: "https://example.com/thumb.jpg",
                  largeImageURL: "https://example.com/large.jpg",
                  isLiked: true)
        ]

        // when
        let viewModel = presenter.viewModel(for: 0)

        // then
        XCTAssertEqual(viewModel.imageURL?.absoluteString, "https://example.com/thumb.jpg")
        XCTAssertEqual(viewModel.isLiked, true)
    }
}

final class ImagesListViewSpy: ImagesListViewControllerProtocol {
    
    
    var presenter: ImagesListPresenterProtocol?
    
    var didReloadAnimatedTableView = false
    
    func reloadAnimatedTableView(oldCount: Int, newCount: Int) {
        didReloadAnimatedTableView = true
    }
    
    func showError(title: String, message: String?, buttonText: String, secondButtonText: String?, completion: (() -> Void)?, secondCompletion: (() -> Void)?) {
            
        }
        
    func presentFullScreenImage(at index: Int?) {
        
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    
    var photosCount: Int {
        return 0
    }
    
    var photos: [Photo] = []
    
    func viewDidLoad() {
    }
    
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
    
    func willDisplayCell(at index: Int) {
    }
    
    func cellHeight(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0
    }
    
    func didTapLike(on cell: ImagesListCell) {
    }
    
    func viewModel(for index: Int) -> PhotoCellViewModel {
        return PhotoCellViewModel(dateText: "", imageURL: nil, isLiked: true)
    }
    
    
}
