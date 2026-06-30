//
//  ScreenshotTests.swift
//  ReshelfBooksUITests
//
//  Drives the seeded sample library and captures full-resolution screenshots for the
//  App Store. Run against an iPhone 6.9" and an iPad 13" simulator; the PNGs are
//  attached to the test result and exported with `xcresulttool export attachments`.
//

import XCTest

final class ScreenshotTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCaptureScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-seedSampleLibrary"]
        app.launch()

        // Seeding wipes + refetches covers over the network, then saves once — so the
        // books only appear (already carrying covers) when seeding has fully finished.
        let dune = app.buttons.containing(
            NSPredicate(format: "label CONTAINS[c] %@", "Dune")
        ).firstMatch
        XCTAssertTrue(dune.waitForExistence(timeout: 120), "Sample library did not seed")
        // Small settle so the cover images finish decoding/rendering.
        sleep(3)

        // 1) Library hero.
        snapshot(app, "01-library")

        // 2) Book detail of a lent book (shows "Lent to Alice" + Return).
        dune.tap()
        XCTAssertTrue(app.buttons["Return book"].waitForExistence(timeout: 10), "Detail did not open")
        sleep(1)
        snapshot(app, "04-book-detail")
        app.buttons["Done"].tap()

        // 3) Search (duplicate-check angle): find an owned title.
        app.buttons["Search"].tap()
        let searchField = app.textFields["Search field"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10), "Search did not open")
        searchField.tap()
        searchField.typeText("Harry")
        // Wait for the debounced result row.
        let result = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS[c] %@", "Harry Potter")
        ).firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 10), "Search result did not appear")
        sleep(1)
        snapshot(app, "05-search")
        app.buttons["Cancel"].tap()

        // Switch to the Scan tab for the scan-driven sheets.
        app.buttons["Scan"].tap()

        // 4) Book Location — manual entry of an OWNED ISBN routes to the "found" sheet.
        lookUp(app, isbn: "9780451524935")   // 1984, already in the library
        let foundTitle = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@", "Book Found", "Place this book")
        ).firstMatch
        XCTAssertTrue(foundTitle.waitForExistence(timeout: 10), "Book Location did not appear")
        snapshot(app, "02-book-location")
        // This sheet auto-dismisses after 5s; close it if it's still up.
        if app.buttons["Done"].exists { app.buttons["Done"].tap() }

        // 5) New Book — manual entry of an UNOWNED ISBN does a live lookup.
        lookUp(app, isbn: "9780544003415")   // The Lord of the Rings, not in the library
        XCTAssertTrue(app.buttons["Add to Library"].waitForExistence(timeout: 30), "New Book did not appear")
        // Let the background cover search finish so the preview shows the real cover
        // instead of the loading spinner.
        let spinner = app.activityIndicators.firstMatch
        let deadline = Date().addingTimeInterval(20)
        while spinner.exists && Date() < deadline { usleep(300_000) }
        sleep(1)
        snapshot(app, "03-new-book")
    }

    /// Captures the Lend sheet mid-entry: a typed borrower name plus the recent-borrower
    /// chips (Alice/Ben, who already hold the seeded lent books).
    @MainActor
    func testCaptureLendSheet() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-seedSampleLibrary"]
        app.launch()

        // Open a NOT-lent book so the Lend action is available.
        let hobbit = app.buttons.containing(
            NSPredicate(format: "label CONTAINS[c] %@", "Hobbit")
        ).firstMatch
        XCTAssertTrue(hobbit.waitForExistence(timeout: 120), "Sample library did not seed")
        sleep(2)
        hobbit.tap()

        let lend = app.buttons["Lend book"]
        XCTAssertTrue(lend.waitForExistence(timeout: 10), "Detail did not open")
        lend.tap()

        let nameField = app.textFields["Name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 10), "Lend sheet did not open")
        nameField.tap()
        nameField.typeText("Sophie")
        sleep(1)
        snapshot(app, "06-lend")
    }

    /// Captures the "Book Returned" result: scanning the lent Dune returns it from Alice
    /// and shows where to reshelve it.
    @MainActor
    func testCaptureReturned() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-seedSampleLibrary"]
        app.launch()

        // Wait for seeding (Dune is seeded as lent to Alice).
        let dune = app.buttons.containing(
            NSPredicate(format: "label CONTAINS[c] %@", "Dune")
        ).firstMatch
        XCTAssertTrue(dune.waitForExistence(timeout: 120), "Sample library did not seed")
        sleep(2)

        // Manual-entry of a LENT book's ISBN routes through the return flow.
        app.buttons["Scan"].tap()
        lookUp(app, isbn: "9780441013593")   // Dune, currently lent to Alice
        let returned = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@", "Book Returned", "Returned from")
        ).firstMatch
        XCTAssertTrue(returned.waitForExistence(timeout: 10), "Return flow did not appear")
        snapshot(app, "07-book-returned")
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
