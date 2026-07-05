//
//  ScreenshotTests.swift
//  ReshelfBooksUITests
//
//  Drives the seeded sample library and captures full-resolution screenshots for the
//  App Store. Run against an iPhone 6.9" and an iPad 13" simulator; the PNGs are
//  attached to the test result and exported with `xcresulttool export attachments`.
//  Snapshot names are the final story order (1..5).
//

import XCTest

final class ScreenshotTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Waits for seeding to finish. A lent book is used as the signal because lent books
    /// sit in the pinned "Lent" section at the top of the library, so their card is
    /// always rendered (unlike shelf books further down a lazy list).
    @MainActor
    private func waitForSeed(_ app: XCUIApplication) {
        let lent = app.buttons.containing(
            NSPredicate(format: "label CONTAINS[c] %@", "Fahrenheit")
        ).firstMatch
        XCTAssertTrue(lent.waitForExistence(timeout: 180), "Sample library did not seed")
    }

    @MainActor
    func testCaptureScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-seedSampleLibrary"]
        app.launch()
        waitForSeed(app)
        sleep(3)   // let covers finish decoding/rendering

        // 2) Library hero (4 books lent to 2 people show in the Lent section).
        snapshot(app, "2-your-library")

        app.buttons["Scan"].tap()

        // 3) Find the shelf — scan an OWNED book (The Gruffalo, on Living - Kids Row).
        lookUp(app, isbn: "9780142403877")
        let found = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@", "Book Found", "Place this book")
        ).firstMatch
        XCTAssertTrue(found.waitForExistence(timeout: 10), "Book Location did not appear")
        snapshot(app, "3-find-the-shelf")
        if app.buttons["Done"].exists { app.buttons["Done"].tap() }

        // 1) Scan to add — an UNOWNED book (Circe by Madeline Miller) via live lookup.
        lookUp(app, isbn: "9780316556347")
        XCTAssertTrue(app.buttons["Add to Library"].waitForExistence(timeout: 30), "New Book did not appear")
        let spinner = app.activityIndicators.firstMatch
        let deadline = Date().addingTimeInterval(20)
        while spinner.exists && Date() < deadline { usleep(300_000) }
        sleep(1)
        snapshot(app, "1-scan-to-add")
    }

    /// Lend sheet mid-entry (Charlotte's Web): a typed borrower plus the recent-borrower
    /// chips (Emma / Liam, who hold the seeded lent books).
    @MainActor
    func testCaptureLendSheet() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-seedSampleLibrary"]
        app.launch()
        waitForSeed(app)

        // Reach Charlotte's Web via Search (robust regardless of its shelf position).
        app.buttons["Search"].tap()
        let field = app.textFields["Search field"]
        XCTAssertTrue(field.waitForExistence(timeout: 10), "Search did not open")
        field.tap()
        field.typeText("Charlotte")
        let row = app.buttons.containing(
            NSPredicate(format: "label CONTAINS[c] %@", "Charlotte's Web")
        ).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), "Search result did not appear")
        row.tap()

        let lend = app.buttons["Lend book"]
        XCTAssertTrue(lend.waitForExistence(timeout: 10), "Book detail did not open")
        lend.tap()

        let nameField = app.textFields["Name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 10), "Lend sheet did not open")
        nameField.tap()
        nameField.typeText("Sophie")
        sleep(1)
        snapshot(app, "4-lend-a-book")
    }

    /// "Book Returned" result: scanning the lent Fahrenheit 451 returns it from Emma and
    /// shows where to reshelve it.
    @MainActor
    func testCaptureReturned() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-seedSampleLibrary"]
        app.launch()
        waitForSeed(app)

        app.buttons["Scan"].tap()
        lookUp(app, isbn: "9781451673319")   // Fahrenheit 451, lent to Emma
        let returned = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@", "Book Returned", "Returned from")
        ).firstMatch
        XCTAssertTrue(returned.waitForExistence(timeout: 10), "Return flow did not appear")
        snapshot(app, "5-scan-to-return")
    }

    // MARK: - Helpers

    private func snapshot(_ app: XCUIApplication, _ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Opens manual ISBN entry (from the scanner), types the ISBN, and taps Look Up.
    /// Opening retries once: on iPad the sheet presentation is occasionally swallowed
    /// when invoked right after another sheet has just dismissed.
    private func lookUp(_ app: XCUIApplication, isbn: String) {
        let enter = app.buttons.containing(
            NSPredicate(format: "label CONTAINS[c] %@", "Enter ISBN")
        ).firstMatch
        XCTAssertTrue(enter.waitForExistence(timeout: 10), "Enter ISBN button missing")
        enter.tap()

        let field = app.textFields.firstMatch
        if !field.waitForExistence(timeout: 5) {
            if enter.exists { enter.tap() }
            XCTAssertTrue(field.waitForExistence(timeout: 8), "ISBN field missing")
        }
        field.tap()
        field.typeText(isbn)

        let button = app.buttons["Look Up Book"]
        if !button.isHittable { app.swipeUp() }
        button.tap()
    }
}
