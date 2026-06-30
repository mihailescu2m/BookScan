//
//  SampleDataSeeder.swift
//  ReshelfBooks
//
//  DEBUG-only sample-library seeder for App Store screenshots. Never compiled into a
//  Release build, and only runs when the app is launched with `-seedSampleLibrary`
//  (passed by the screenshot UI test) — so it has no effect on normal use.
//

#if DEBUG
import CoreData
import UIKit

extension PersistenceController {

    /// One sample book to create. Cover art is fetched live from the real lookup
    /// service so the screenshots show genuine covers.
    private struct SampleBook {
        let isbn: String
        let title: String
        let author: String
        let year: String
        let shelf: String
        /// Borrower name when this book should be seeded as lent (nil = on its shelf).
        var lentTo: String? = nil
    }

    private static let sampleBooks: [SampleBook] = [
        // Living Room Top Row — classic & literary fiction (Dune lent, 9 remain on shelf)
        .init(isbn: "9780441013593", title: "Dune", author: "Frank Herbert", year: "1965", shelf: "Living Room Top Row", lentTo: "Alice"),
        .init(isbn: "9780547928227", title: "The Hobbit", author: "J.R.R. Tolkien", year: "1937", shelf: "Living Room Top Row"),
        .init(isbn: "9780451524935", title: "1984", author: "George Orwell", year: "1949", shelf: "Living Room Top Row"),
        .init(isbn: "9780141439518", title: "Pride and Prejudice", author: "Jane Austen", year: "1813", shelf: "Living Room Top Row"),
        .init(isbn: "9780060850524", title: "Brave New World", author: "Aldous Huxley", year: "1932", shelf: "Living Room Top Row"),
        .init(isbn: "9781451673319", title: "Fahrenheit 451", author: "Ray Bradbury", year: "1953", shelf: "Living Room Top Row"),
        .init(isbn: "9780316769488", title: "The Catcher in the Rye", author: "J.D. Salinger", year: "1951", shelf: "Living Room Top Row"),
        .init(isbn: "9780061120084", title: "To Kill a Mockingbird", author: "Harper Lee", year: "1960", shelf: "Living Room Top Row"),
        .init(isbn: "9780743273565", title: "The Great Gatsby", author: "F. Scott Fitzgerald", year: "1925", shelf: "Living Room Top Row"),
        .init(isbn: "9780399501487", title: "Lord of the Flies", author: "William Golding", year: "1954", shelf: "Living Room Top Row"),
        // Office Left — programming & non-fiction (Sapiens lent, 9 remain on shelf)
        .init(isbn: "9780132350884", title: "Clean Code", author: "Robert C. Martin", year: "2008", shelf: "Office Left"),
        .init(isbn: "9780201616224", title: "The Pragmatic Programmer", author: "Andrew Hunt", year: "1999", shelf: "Office Left"),
        .init(isbn: "9780062316097", title: "Sapiens", author: "Yuval Noah Harari", year: "2015", shelf: "Office Left", lentTo: "Ben"),
        .init(isbn: "9780374533557", title: "Thinking, Fast and Slow", author: "Daniel Kahneman", year: "2011", shelf: "Office Left"),
        .init(isbn: "9780201835953", title: "The Mythical Man-Month", author: "Frederick P. Brooks Jr.", year: "1975", shelf: "Office Left"),
        .init(isbn: "9780201485677", title: "Refactoring", author: "Martin Fowler", year: "1999", shelf: "Office Left"),
        .init(isbn: "9780201633610", title: "Design Patterns", author: "Erich Gamma", year: "1994", shelf: "Office Left"),
        .init(isbn: "9780262033848", title: "Introduction to Algorithms", author: "Thomas H. Cormen", year: "2009", shelf: "Office Left"),
        .init(isbn: "9780131103627", title: "The C Programming Language", author: "Brian W. Kernighan", year: "1988", shelf: "Office Left"),
        .init(isbn: "9780735619678", title: "Code Complete", author: "Steve McConnell", year: "2004", shelf: "Office Left"),
        // Kids Room — picture & children's books (9 on shelf)
        .init(isbn: "9780064431781", title: "Where the Wild Things Are", author: "Maurice Sendak", year: "1963", shelf: "Kids Room"),
        .init(isbn: "9780142410370", title: "Matilda", author: "Roald Dahl", year: "1988", shelf: "Kids Room"),
        .init(isbn: "9780590353427", title: "Harry Potter and the Sorcerer's Stone", author: "J.K. Rowling", year: "1997", shelf: "Kids Room"),
        .init(isbn: "9780399226908", title: "The Very Hungry Caterpillar", author: "Eric Carle", year: "1969", shelf: "Kids Room"),
        .init(isbn: "9780394800165", title: "Green Eggs and Ham", author: "Dr. Seuss", year: "1960", shelf: "Kids Room"),
        .init(isbn: "9780394800011", title: "The Cat in the Hat", author: "Dr. Seuss", year: "1957", shelf: "Kids Room"),
        .init(isbn: "9780064410939", title: "Charlotte's Web", author: "E.B. White", year: "1952", shelf: "Kids Room"),
        .init(isbn: "9780142403877", title: "The Gruffalo", author: "Julia Donaldson", year: "1999", shelf: "Kids Room"),
        .init(isbn: "9780064430173", title: "Goodnight Moon", author: "Margaret Wise Brown", year: "1947", shelf: "Kids Room"),
    ]

    /// Shelf creation order (so they appear top-to-bottom as listed).
    private static let sampleShelfOrder = ["Living Room Top Row", "Office Left", "Kids Room"]

    /// Wipes any local data and seeds a realistic sample library with live cover art.
    /// No-op unless launched with `-seedSampleLibrary`.
    @MainActor
    func seedSampleLibraryIfRequested() async {
        guard CommandLine.arguments.contains("-seedSampleLibrary") else { return }

        wipeAllLocalData()

        // Fetch every cover concurrently up front so the slow network calls overlap.
        let covers = await fetchCovers(for: Self.sampleBooks)

        // Create shelves in a stable order.
        var shelvesByName: [String: Shelf] = [:]
        for name in Self.sampleShelfOrder {
            shelvesByName[name] = makeShelf(name: name)
        }

        for sample in Self.sampleBooks {
            let book = makeBook(
                isbn: sample.isbn,
                title: sample.title,
                author: sample.author,
                yearPublished: sample.year,
                coverImageURL: nil,
                shelf: shelvesByName[sample.shelf]
            )
            book.coverImageData = covers[sample.isbn]

            if let borrower = sample.lentTo, let lending = lendingShelf(creatingIfNeeded: true) {
                book.lend(to: lending, borrower: borrower)
            }
        }

        save()
    }

    /// Deletes all libraries, shelves and books from the local stores so each seeded
    /// run starts from a clean, deterministic state.
    @MainActor
    private func wipeAllLocalData() {
        for entity in ["Book", "Shelf", "Library"] {
            let request = NSFetchRequest<NSManagedObject>(entityName: entity)
            for object in (try? viewContext.fetch(request)) ?? [] {
                viewContext.delete(object)
            }
        }
        save()
    }

    /// Downloads and normalizes cover art for every sample book concurrently.
    private func fetchCovers(for books: [SampleBook]) async -> [String: Data] {
        await withTaskGroup(of: (String, Data?).self) { group in
            for book in books {
                group.addTask {
                    (book.isbn, await Self.coverData(isbn: book.isbn, title: book.title, author: book.author))
                }
            }
            var result: [String: Data] = [:]
            for await (isbn, data) in group where data != nil {
                result[isbn] = data
            }
            return result
        }
    }

    /// ISBN-keyed cover first, then a title/author fallback; normalized for storage.
    private static func coverData(isbn: String, title: String, author: String) async -> Data? {
        let service = ISBNLookupService.shared
        if let url = await service.findCoverURLByISBN(isbn: isbn),
           let raw = try? await service.downloadCoverImage(from: url),
           let data = CoverImage.normalizedData(from: raw) {
            return data
        }
        if let url = await service.findCoverURL(title: title, author: author),
           let raw = try? await service.downloadCoverImage(from: url),
           let data = CoverImage.normalizedData(from: raw) {
            return data
        }
        return nil
    }
}
#endif
