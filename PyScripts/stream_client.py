import cv2
import grpc
import video_stream_pb2
import video_stream_pb2_grpc
import numpy as np

def generate_frames():
    cap = cv2.VideoCapture(0)
    resolution = (640, 480)
#    print(f"Resolution: {resolution}")
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, resolution[0])
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, resolution[1])
    while True:
        ret, image = cap.read() # reads frame that has stereo images side by side
        if not ret:
            print("failed to grab")
            break

        # split image in half
        image = cv2.rotate(image, cv2.ROTATE_180)
        w = image.shape[1]//2
        h = image.shape[0]
        im_left = image[:, :w]
        im_right = image[:, w:2*w]
        
        _, buffer = cv2.imencode('.jpg', im_left)
        _, buffer2 = cv2.imencode('.jpg', im_right)
        print("encoded both")
        yield video_stream_pb2.Frame(left=buffer.tobytes(), right=buffer2.tobytes())

def run():
    channel = grpc.insecure_channel('10.31.169.198:50051')
    stub = video_stream_pb2_grpc.VideoStreamStub(channel)
    response = stub.SendFrame(generate_frames())
    print("streamack message:", response.message)

if __name__ == '__main__':
   run()
#   generate_frames()
