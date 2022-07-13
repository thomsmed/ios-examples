//
//  main.swift
//  GRPCFTWServer
//
//  Created by Thomas Asheim Smedmann on 06/06/2022.
//

import Foundation
import NIO
import NIOSSL
import GRPC

// Create an event loop group for the server to run on.
let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
defer {
    try! group.syncShutdownGracefully()
}

let fooServiceProvider = DefaultFooServiceProvider()
let barServiceProvider = DefaultBarServiceProvider()

// Start the server and print its address once it has started.
let server = Server
    .usingTLS(
        with: .makeClientConfigurationBackedByNIOSSL(
            certificateChain: try NIOSSLCertificate.fromPEMFile("cert.pem").map { .certificate($0) },
            privateKey: nil,
            trustRoots: .default,
            certificateVerification: .noHostnameVerification,
            hostnameOverride: nil,
            customVerificationCallback: nil
        ),
        on: group
    )
//    .insecure(group: group)
    .withServiceProviders([
        fooServiceProvider,
        barServiceProvider
    ])
    .bind(host: "localhost", port: 9898)

server.map {
    $0.channel.localAddress
}.whenSuccess { address in
    print("server started on port \(address!.port!)")
}

// Wait on the server's `onClose` future to stop the program from exiting.
_ = try server.flatMap {
    $0.onClose
}.wait()
