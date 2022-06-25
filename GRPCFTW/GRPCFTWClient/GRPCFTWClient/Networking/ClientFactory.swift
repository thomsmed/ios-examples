//
//  ClientFactory.swift
//  GRPCFTWClient
//
//  Created by Thomas Asheim Smedmann on 06/06/2022.
//

import NIO
import GRPC

protocol ClientFactory: AnyObject {

    // Expose the underlying EventLoop(s) in case we want to run work on it.
    var eventLoop: EventLoop { get }

    func fooServiceClient() -> Grpcftw_FooServiceClientProtocol
    func barServiceClient() -> Grpcftw_BarServiceClientProtocol
}

final class DefaultClientFactory {

    enum Header: String {
        case appVersion = "app-version"
        case appInstance = "app-instance"
    }

    // GRPC Performance best practices:
    // https://grpc.io/docs/guides/performance/

    // TODO: Short about eventLoops vs Threads and Network.framework
    private lazy var eventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1)

    private lazy var sharedChannel: GRPCChannel = {
        do {
            return try GRPCChannelPool.with(
                target: .host(host, port: port),
                transportSecurity: .tls(
                    GRPCTLSConfiguration.makeClientDefault(compatibleWith: eventLoopGroup)
                ),
                eventLoopGroup: eventLoopGroup
            ) { configuration in
                // Additional configuration, like keepalive.
                // Note: Keepalive should in most circumstances not be necessary.
                configuration.keepalive = ClientConnectionKeepalive(
                    interval: .seconds(15),
                    timeout: .seconds(10)
                )
            }
        } catch {
            fatalError("Failed to open GRPC channel")
        }
    }()

    private let host: String
    private let port: Int

    // Shared metadata/headers across all GRPCClients
    private lazy var sharedHeaders: [Header: String] = [:]

    private var sharedFooServiceClient: Grpcftw_FooServiceClientProtocol?
    private var sharedBarServiceClient: Grpcftw_BarServiceClientProtocol?

    init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
}

// MARK: Public methods

extension DefaultClientFactory {

    // Expose the option to set shared client stub headers
    func set(header: Header, value: String?) {
        sharedHeaders[header] = value

        sharedFooServiceClient?.defaultCallOptions.customMetadata = .init(
            sharedHeaders.map { ($0.rawValue, $1) }
        )
        sharedBarServiceClient?.defaultCallOptions.customMetadata = .init(
            sharedHeaders.map { ($0.rawValue, $1) }
        )
    }
}

// MARK: ClientFactory

extension DefaultClientFactory: ClientFactory {

    var eventLoop: EventLoop {
        eventLoopGroup.any()
    }

    func fooServiceClient() -> Grpcftw_FooServiceClientProtocol {
        if let fooServiceClient = sharedFooServiceClient {
            return fooServiceClient
        }

        let fooServiceClient = Grpcftw_FooServiceClient(
            channel: sharedChannel,
            defaultCallOptions: .init(
                customMetadata: .init(sharedHeaders.map { ($0.rawValue, $1) }),
                timeLimit: .timeout(.seconds(15))
            )
        )

        sharedFooServiceClient = fooServiceClient

        return fooServiceClient
    }

    func barServiceClient() -> Grpcftw_BarServiceClientProtocol {
        if let barServiceClient = sharedBarServiceClient {
            return barServiceClient
        }

        let barServiceClient = Grpcftw_BarServiceClient(
            channel: sharedChannel,
            defaultCallOptions: .init(
                customMetadata: .init(sharedHeaders.map { ($0.rawValue, $1) }),
                timeLimit: .timeout(.seconds(15))
            )
        )

        sharedBarServiceClient = barServiceClient

        return barServiceClient
    }
}
