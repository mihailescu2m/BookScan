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

    /// Shelf creation order (so they appear top-to-bottom as listed).
    private static let sampleShelfOrder = [
        "Kitchen", "Study - Middle Row", "Living - Kids Row",
        "Living - Fantasy Row", "Living - Top Row",
    ]

    // ~15 real books per shelf, themed to the shelf name. Four are seeded as lent to
    // two people (Emma / Liam) so the library screenshot shows an active lending shelf.
    private static let sampleBooks: [SampleBook] = [
        // Kitchen — cookbooks
        .init(isbn: "9781476753836", title: "Salt, Fat, Acid, Heat", author: "Samin Nosrat", year: "2017", shelf: "Kitchen"),
        .init(isbn: "9780393081084", title: "The Food Lab", author: "J. Kenji López-Alt", year: "2015", shelf: "Kitchen"),
        .init(isbn: "9781607749165", title: "Ottolenghi Simple", author: "Yotam Ottolenghi", year: "2018", shelf: "Kitchen"),
        .init(isbn: "9780375413407", title: "Mastering the Art of French Cooking", author: "Julia Child", year: "2001", shelf: "Kitchen"),
        .init(isbn: "9781607743941", title: "Jerusalem", author: "Yotam Ottolenghi", year: "2012", shelf: "Kitchen"),
        .init(isbn: "9780743246262", title: "The Joy of Cooking", author: "Irma S. Rombauer", year: "2006", shelf: "Kitchen"),
        .init(isbn: "9780764578656", title: "How to Cook Everything", author: "Mark Bittman", year: "2008", shelf: "Kitchen"),
        .init(isbn: "9781101903919", title: "Cravings", author: "Chrissy Teigen", year: "2016", shelf: "Kitchen"),
        .init(isbn: "9780062820150", title: "Magnolia Table", author: "Joanna Gaines", year: "2018", shelf: "Kitchen"),
        .init(isbn: "9780525577072", title: "Half Baked Harvest Super Simple", author: "Tieghan Gerard", year: "2019", shelf: "Kitchen"),
        .init(isbn: "9780394584041", title: "Essentials of Classic Italian Cooking", author: "Marcella Hazan", year: "1992", shelf: "Kitchen"),
        .init(isbn: "9781452101248", title: "Plenty", author: "Yotam Ottolenghi", year: "2011", shelf: "Kitchen"),
        .init(isbn: "9780618443369", title: "Baking: From My Home to Yours", author: "Dorie Greenspan", year: "2006", shelf: "Kitchen"),
        .init(isbn: "9781580082686", title: "The Bread Baker's Apprentice", author: "Peter Reinhart", year: "2001", shelf: "Kitchen"),
        .init(isbn: "9780307408563", title: "Momofuku", author: "David Chang", year: "2009", shelf: "Kitchen"),

        // Study - Middle Row — serious non-fiction (Sapiens lent to Liam)
        .init(isbn: "9780062316097", title: "Sapiens", author: "Yuval Noah Harari", year: "2015", shelf: "Study - Middle Row", lentTo: "Liam"),
        .init(isbn: "9780374533557", title: "Thinking, Fast and Slow", author: "Daniel Kahneman", year: "2011", shelf: "Study - Middle Row"),
        .init(isbn: "9780553380163", title: "A Brief History of Time", author: "Stephen Hawking", year: "1998", shelf: "Study - Middle Row"),
        .init(isbn: "9780345539434", title: "Cosmos", author: "Carl Sagan", year: "2013", shelf: "Study - Middle Row"),
        .init(isbn: "9780393317558", title: "Guns, Germs, and Steel", author: "Jared Diamond", year: "1999", shelf: "Study - Middle Row"),
        .init(isbn: "9780198788607", title: "The Selfish Gene", author: "Richard Dawkins", year: "2016", shelf: "Study - Middle Row"),
        .init(isbn: "9780465026562", title: "Gödel, Escher, Bach", author: "Douglas Hofstadter", year: "1999", shelf: "Study - Middle Row"),
        .init(isbn: "9780399590504", title: "Educated", author: "Tara Westover", year: "2018", shelf: "Study - Middle Row"),
        .init(isbn: "9780060731335", title: "Freakonomics", author: "Steven D. Levitt", year: "2009", shelf: "Study - Middle Row"),
        .init(isbn: "9780062464316", title: "Homo Deus", author: "Yuval Noah Harari", year: "2017", shelf: "Study - Middle Row"),
        .init(isbn: "9780812968255", title: "Meditations", author: "Marcus Aurelius", year: "2002", shelf: "Study - Middle Row"),
        .init(isbn: "9780140455113", title: "The Republic", author: "Plato", year: "2007", shelf: "Study - Middle Row"),
        .init(isbn: "9780062397348", title: "A People's History of the United States", author: "Howard Zinn", year: "2015", shelf: "Study - Middle Row"),
        .init(isbn: "9780226458120", title: "The Structure of Scientific Revolutions", author: "Thomas S. Kuhn", year: "2012", shelf: "Study - Middle Row"),
        .init(isbn: "9780316017930", title: "Outliers", author: "Malcolm Gladwell", year: "2008", shelf: "Study - Middle Row"),

        // Living - Kids Row — children's books (Gruffalo + Charlotte's Web used by tests)
        .init(isbn: "9780142403877", title: "The Gruffalo", author: "Julia Donaldson", year: "1999", shelf: "Living - Kids Row"),
        .init(isbn: "9780064431781", title: "Where the Wild Things Are", author: "Maurice Sendak", year: "2012", shelf: "Living - Kids Row"),
        .init(isbn: "9780399226908", title: "The Very Hungry Caterpillar", author: "Eric Carle", year: "1994", shelf: "Living - Kids Row"),
        .init(isbn: "9780064410939", title: "Charlotte's Web", author: "E.B. White", year: "2012", shelf: "Living - Kids Row"),
        .init(isbn: "9780394800165", title: "Green Eggs and Ham", author: "Dr. Seuss", year: "1960", shelf: "Living - Kids Row"),
        .init(isbn: "9780394800011", title: "The Cat in the Hat", author: "Dr. Seuss", year: "1957", shelf: "Living - Kids Row"),
        .init(isbn: "9780064430173", title: "Goodnight Moon", author: "Margaret Wise Brown", year: "2007", shelf: "Living - Kids Row"),
        .init(isbn: "9780142410370", title: "Matilda", author: "Roald Dahl", year: "2007", shelf: "Living - Kids Row"),
        .init(isbn: "9780723247708", title: "The Tale of Peter Rabbit", author: "Beatrix Potter", year: "2002", shelf: "Living - Kids Row"),
        .init(isbn: "9780140501735", title: "Corduroy", author: "Don Freeman", year: "1976", shelf: "Living - Kids Row"),
        .init(isbn: "9780763642648", title: "Guess How Much I Love You", author: "Sam McBratney", year: "2008", shelf: "Living - Kids Row"),
        .init(isbn: "9780140501827", title: "The Snowy Day", author: "Ezra Jack Keats", year: "1976", shelf: "Living - Kids Row"),
        .init(isbn: "9780805047905", title: "Brown Bear, Brown Bear, What Do You See?", author: "Bill Martin Jr.", year: "1996", shelf: "Living - Kids Row"),
        .init(isbn: "9780142410318", title: "Charlie and the Chocolate Factory", author: "Roald Dahl", year: "2007", shelf: "Living - Kids Row"),
        .init(isbn: "9780679805274", title: "Oh, the Places You'll Go!", author: "Dr. Seuss", year: "1990", shelf: "Living - Kids Row"),

        // Living - Fantasy Row — fantasy (The Hobbit lent to Liam)
        .init(isbn: "9780547928227", title: "The Hobbit", author: "J.R.R. Tolkien", year: "1937", shelf: "Living - Fantasy Row", lentTo: "Liam"),
        .init(isbn: "9780553593716", title: "A Game of Thrones", author: "George R.R. Martin", year: "1996", shelf: "Living - Fantasy Row"),
        .init(isbn: "9780756404741", title: "The Name of the Wind", author: "Patrick Rothfuss", year: "2007", shelf: "Living - Fantasy Row"),
        .init(isbn: "9780765326355", title: "The Way of Kings", author: "Brandon Sanderson", year: "2010", shelf: "Living - Fantasy Row"),
        .init(isbn: "9780765350381", title: "Mistborn: The Final Empire", author: "Brandon Sanderson", year: "2006", shelf: "Living - Fantasy Row"),
        .init(isbn: "9780590353427", title: "Harry Potter and the Sorcerer's Stone", author: "J.K. Rowling", year: "1997", shelf: "Living - Fantasy Row"),
        .init(isbn: "9780547928210", title: "The Fellowship of the Ring", author: "J.R.R. Tolkien", year: "1954", shelf: "Living - Fantasy Row"),
        .init(isbn: "9780380789030", title: "American Gods", author: "Neil Gaiman", year: "2001", shelf: "Living - Fantasy Row"),
        .init(isbn: "9780765334336", title: "The Eye of the World", author: "Robert Jordan", year: "1990", shelf: "Living - Fantasy Row"),
        .init(isbn: "9780553588941", title: "The Lies of Locke Lamora", author: "Scott Lynch", year: "2006", shelf: "Living - Fantasy Row"),
        .init(isbn: "9780553573398", title: "Assassin's Apprentice", author: "Robin Hobb", year: "1995", shelf: "Living - Fantasy Row"),
        .init(isbn: "9780547773742", title: "A Wizard of Earthsea", author: "Ursula K. Le Guin", year: "2012", shelf: "Living - Fantasy Row"),
        .init(isbn: "9781635570298", title: "The Priory of the Orange Tree", author: "Samantha Shannon", year: "2019", shelf: "Living - Fantasy Row"),
        .init(isbn: "9780062225672", title: "The Color of Magic", author: "Terry Pratchett", year: "2005", shelf: "Living - Fantasy Row"),
        .init(isbn: "9780316387316", title: "The Blade Itself", author: "Joe Abercrombie", year: "2007", shelf: "Living - Fantasy Row"),

        // Living - Top Row — literary & classics (Fahrenheit 451 + 1984 lent to Emma)
        .init(isbn: "9781451673319", title: "Fahrenheit 451", author: "Ray Bradbury", year: "1953", shelf: "Living - Top Row", lentTo: "Emma"),
        .init(isbn: "9780451524935", title: "1984", author: "George Orwell", year: "1949", shelf: "Living - Top Row", lentTo: "Emma"),
        .init(isbn: "9780061120084", title: "To Kill a Mockingbird", author: "Harper Lee", year: "2006", shelf: "Living - Top Row"),
        .init(isbn: "9780141439518", title: "Pride and Prejudice", author: "Jane Austen", year: "2003", shelf: "Living - Top Row"),
        .init(isbn: "9780743273565", title: "The Great Gatsby", author: "F. Scott Fitzgerald", year: "2004", shelf: "Living - Top Row"),
        .init(isbn: "9780060850524", title: "Brave New World", author: "Aldous Huxley", year: "2006", shelf: "Living - Top Row"),
        .init(isbn: "9780316769488", title: "The Catcher in the Rye", author: "J.D. Salinger", year: "1991", shelf: "Living - Top Row"),
        .init(isbn: "9780385333849", title: "Slaughterhouse-Five", author: "Kurt Vonnegut", year: "1999", shelf: "Living - Top Row"),
        .init(isbn: "9780399501487", title: "Lord of the Flies", author: "William Golding", year: "2003", shelf: "Living - Top Row"),
        .init(isbn: "9780141441146", title: "Jane Eyre", author: "Charlotte Brontë", year: "2006", shelf: "Living - Top Row"),
        .init(isbn: "9780143107637", title: "Crime and Punishment", author: "Fyodor Dostoevsky", year: "2003", shelf: "Living - Top Row"),
        .init(isbn: "9780141439570", title: "The Picture of Dorian Gray", author: "Oscar Wilde", year: "2003", shelf: "Living - Top Row"),
        .init(isbn: "9780142437247", title: "Moby-Dick", author: "Herman Melville", year: "2002", shelf: "Living - Top Row"),
        .init(isbn: "9780140177398", title: "Of Mice and Men", author: "John Steinbeck", year: "1993", shelf: "Living - Top Row"),
        .init(isbn: "9780143039433", title: "The Grapes of Wrath", author: "John Steinbeck", year: "2006", shelf: "Living - Top Row"),
        .init(isbn: "9780684801223", title: "The Old Man and the Sea", author: "Ernest Hemingway", year: "1952", shelf: "Living - Top Row"),
        .init(isbn: "9780141439471", title: "Frankenstein", author: "Mary Shelley", year: "1818", shelf: "Living - Top Row"),
    ]

    /// Wipes any local data and seeds a realistic sample library with live cover art.
    /// No-op unless launched with `-seedSampleLibrary`.
    @MainActor
    func seedSampleLibraryIfRequested() async {
        guard CommandLine.arguments.contains("-seedSampleLibrary") else { return }

        wipeAllLocalData()

        // Fetch every cover concurrently (bounded) up front so the slow network calls
        // overlap without launching hundreds of requests at once.
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

    /// Downloads and normalizes cover art for every sample book, capped to a handful
    /// of concurrent downloads so the sources aren't hammered.
    private func fetchCovers(for books: [SampleBook]) async -> [String: Data] {
        let maxConcurrent = 12
        var result: [String: Data] = [:]
        await withTaskGroup(of: (String, Data?).self) { group in
            var next = 0
            while next < min(maxConcurrent, books.count) {
                let b = books[next]; next += 1
                group.addTask { (b.isbn, await Self.coverData(isbn: b.isbn, title: b.title, author: b.author)) }
            }
            while let (isbn, data) = await group.next() {
                if let data { result[isbn] = data }
                if next < books.count {
                    let b = books[next]; next += 1
                    group.addTask { (b.isbn, await Self.coverData(isbn: b.isbn, title: b.title, author: b.author)) }
                }
            }
        }
        return result
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
