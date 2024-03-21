import GRPC
import NIO
import UIKit

class VideoStreamServer {
    private var server: EventLoopFuture<Server>?
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private var newImageHandler: ((UIImage) -> Void)?

    // Singleton instance
    static let shared = VideoStreamServer()

    private init() {}

    func start(newImageHandler: @escaping (UIImage) -> Void) {
        self.newImageHandler = newImageHandler
        
        let host = "0.0.0.0"
        let port = 50051
        
        // Define the provider for your gRPC service
        let provider = VideoStreamProvider { [weak self] image in
            self?.newImageHandler?(image)
        }
        
        // Start the gRPC server
        server = Server.insecure(group: group)
            .withServiceProviders([provider])
            .bind(host: host, port: port)
        
        server?.whenSuccess { server in
            print("Server started on port \(server.channel.localAddress!)")
        }
    }

    deinit {
        // Shutdown the server when the instance is deallocated
        try? server?.flatMap { $0.close() }.wait()
        try? group.syncShutdownGracefully()
    }
}

final class VideoStreamProvider: Video_VideoStreamAsyncProvider {
    var interceptors: Video_VideoStreamServerInterceptorFactoryProtocol?

    private var imageUpdateHandler: (UIImage) -> Void

    init(imageUpdateHandler: @escaping (UIImage) -> Void) {
        self.imageUpdateHandler = imageUpdateHandler
    }
    
       
    func sendFrame(requestStream: GRPCAsyncRequestStream<Video_Frame>, context: GRPCAsyncServerCallContext) async throws -> Video_StreamAck {
        for try await frame in requestStream {
            let imageData = frame.left
            if let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.imageUpdateHandler(image)
                }
            }
        }
        return Video_StreamAck.with {
            $0.message = "All frames received successfully"
        }
    }
}
