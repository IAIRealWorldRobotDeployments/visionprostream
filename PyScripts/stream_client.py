import cv2
import grpc
import video_stream_pb2
import video_stream_pb2_grpc

def generate_frames():
    cap = cv2.VideoCapture(0)
    # while True:
    while True:
        ret, frame = cap.read()
	#placeholder for second camera
        frame2 = cv2.imread("./car.jpg")
        if not ret:
            print("failed to grab")
            # break
        
        _, buffer = cv2.imencode('.jpg', frame)
        _, buffer2 = cv2.imencode('.jpg', frame2)
        print("encoded both")
        yield video_stream_pb2.Frame(left=buffer.tobytes(), right=buffer2.tobytes())

def run():
    channel = grpc.insecure_channel('10.29.169.33:50051')
    stub = video_stream_pb2_grpc.VideoStreamStub(channel)
    # response = stub.Hello(video_stream_pb2.HelloRequest(greeting='ClientHere'))
    # if response.reply:
    #     print(f"connection established: {response.reply}")
    # else:
    #     print("failed to establish connection")
    response = stub.SendFrame(generate_frames())
    print("streamack message:", response.message)

if __name__ == '__main__':
    run()
