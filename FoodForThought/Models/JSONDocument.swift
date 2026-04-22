import SwiftUI
import UniformTypeIdentifiers

/// A document type for handling JSON files in the app.
struct JSONDocument: FileDocument {
    /// The content types that can be read.
    static var readableContentTypes: [UTType] { [.json] }
    /// The content types that can be written.
    static var writableContentTypes: [UTType] { [.json] }
    
    /// The data stored in the document.
    var data: Data
    
    /// Initializes a new JSONDocument with the given data.
    /// - Parameter data: The data to store.
    init(data: Data) {
        self.data = data
    }
    
    /// Initializes a JSONDocument from a read configuration.
    /// - Parameter configuration: The read configuration.
    /// - Throws: An error if the data cannot be read.
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    /// Writes the document data to a file wrapper.
    /// - Parameter configuration: The write configuration.
    /// - Returns: A file wrapper containing the data.
    /// - Throws: An error if writing fails.
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}