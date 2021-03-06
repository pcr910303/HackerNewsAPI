import XCTest
import PromiseKit
@testable import HackerNewsAPI

final class HackerNewsAPITests: XCTestCase {

    func testSuccessfulLogin() {
        do {
            let token = try hang(HackerNewsAPI.login(toAccount: "hntestacc", password: "hntestpwd"))
            XCTAssertEqual(token.cookie.name, "user")
        } catch {
            XCTFail("Error \(error) thrown.")
        }
    }

    func testUnsuccessfulLogin() {
        let promise = HackerNewsAPI.login(toAccount: "hntestacc", password: "hntestpwd!")
        XCTAssertThrowsError(try hang(promise)) { error in
            guard let error = error as? HackerNewsAPI.APIError else {
                XCTFail()
                return
            }
            switch error {
            case .loginFailed:
                return
            default:
                XCTFail()
            }
        }
    }

    func testLoadingTopItems() {
        do {
            let items = try hang(HackerNewsAPI.topItems())
            XCTAssertEqual(items.count, 30)
        } catch {
            XCTFail("Error \(error) thrown.")
        }
    }

    func testLoadingNewItems() {
        do {
            let items = try hang(HackerNewsAPI.newItems())
            XCTAssertEqual(items.count, 30)
        } catch {
            XCTFail("Error \(error) thrown.")
        }
    }

    func testLoadingTopLevelItem() {
        do {
            let items = try hang(HackerNewsAPI.topItems())
            let item = items[0]
            _ = try hang(HackerNewsAPI.topLevelItem(from: item))
        } catch {
            XCTFail("Error \(error) thrown.")
        }
    }

    func testLoadingURLStory() {
        do {
            let token = try hang(HackerNewsAPI.login(toAccount: "hntestacc", password: "hntestpwd"))
            let story = try hang(HackerNewsAPI.story(withID: 21997622, token: token))
            XCTAssertEqual(story.authorName, "pcr910303")
            XCTAssertEqual(story.id, 21997622)
            XCTAssertEqual(story.score, 115)
            XCTAssertEqual(
                story.content,
                .url(URL(string: "http://ijzerenhein.github.io/autolayout.js/")!)
            )
            XCTAssertEqual(story.title,
                           "Apple's auto layout and visual format language for JavaScript (2016)")
            XCTAssertEqual(story.commentCount, 29)
            XCTAssertEqual(story.comments.count, 9)
            XCTAssertEqual(story.comments[0].comments.count, 2)
            XCTAssert(story.comments[0].text.hasPrefix("I find this layout"))
            XCTAssertEqual(story.comments[0].actions.map({ $0.kind }), [.upvote])
            XCTAssertEqual(story.isCommentable, false)
        } catch {
            XCTFail("Error \(error) thrown.")
        }
    }

    func testLoadingTextStory() {
        do {
            let token = try hang(HackerNewsAPI.login(toAccount: "hntestacc", password: "hntestpwd"))
            let story = try hang(HackerNewsAPI.story(withID: 121003, token: token))
            XCTAssertEqual(story.authorName, "tel")
            XCTAssertEqual(story.id, 121003)
            XCTAssertEqual(story.score, 25)
            XCTAssert(story.content.text?.hasPrefix("or HN: the Next Iteration") ?? false)
            XCTAssertEqual(story.title, "Ask HN: The Arc Effect")
            XCTAssertEqual(story.actions.map({ $0.kind }), [.upvote])
        } catch {
            XCTFail("Error \(error) thrown.")
        }
    }

    func testLoadingURLJob() {
        do {
            let job = try hang(HackerNewsAPI.job(withID: 22188212))
            XCTAssertEqual(job.id, 22188212)
            XCTAssertEqual(job.title, "XIX (YC W17) Is Hiring Engineers in San Francisco")
            XCTAssertEqual(job.content, .url(URL(string: "https://jobs.lever.co/xix")!))
        } catch {
            XCTFail("Error \(error) thrown.")
        }
    }

    func testLoadingTextJob() {
        do {
            let job = try hang(HackerNewsAPI.job(withID: 192327))
            XCTAssertEqual(job.id, 192327)
            XCTAssertEqual(job.ageDescription, "on May 16, 2008")
            XCTAssertEqual(job.title, "Justin.tv is looking for a Lead Flash Engineer!")
            XCTAssert(job.content.text?.hasPrefix("Justin.tv is the biggest live") ?? false)
        } catch {
            XCTFail("Error \(error) thrown.")
        }
    }
}
