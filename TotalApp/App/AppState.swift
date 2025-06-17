//
//  AppState.swift
//  TotalApp
//
//  Created by Rafal Bereski on 20/05/2025.
//

public enum AppState {
    case loading
    case setup
    case error(DataStoreError)
    case ready
}
