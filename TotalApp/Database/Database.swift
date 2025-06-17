//
//  Database.swift
//  TotalApp
//
//  Created by Rafal Bereski on 21/04/2025.
//

import SwiftData

@MainActor
public struct Database {
    
    // This approach for working with SwiftData in the background (ensuring that ModelActor type does not operate
    // on the main thread) is based on guidance from the following blog post: https://www.massicotte.org/model-actor
    
    @ModelActor
    public actor Background {
        static nonisolated func create(container: ModelContainer) async -> Background {
            Background(modelContainer: container)
        }
    }
    
    public let mainContext: ModelContext
    private let task: Task<Background, Never>
    
    public var background: Background {
        get async { await task.value }
    }
    
    public init(inMemory: Bool) throws(DataStoreError) {
        do {
            let schema = Schema(versionedSchema: SchemaV1.self)
            let cfg = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
            let container = try ModelContainer(for: schema, configurations: [cfg])
            self.mainContext = container.mainContext
            self.task = Task.detached(priority: .background) { await Background.create(container: container) }
        } catch let e {
            throw .initError("An error occurred while initializing the database.", innerError: e)
        }
    }
}

public extension ModelActor {
    func withContext<T, Failure: Error>(
        _ block: @Sendable (isolated Self, ModelContext) async throws(Failure) -> sending T
    ) async throws(Failure) -> sending T {
        try await block(self, modelContext)
    }
    
    func insert<T: PersistentModel>(_ entity: T) {
        modelContext.insert(entity)
    }
    
    func delete<T: PersistentModel>(model: T.Type) throws {
        try modelContext.delete(model: model)
    }
    
    func save() throws {
        try modelContext.save()
    }
}


public extension ModelContext {
    func fetchOne<T: PersistentModel>() throws -> T? {
        var fd = FetchDescriptor<T>()
        fd.fetchLimit = 1
        return try fetch(fd).first
    }
}
