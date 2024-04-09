# import cv2
# import grpc
# import video_stream_pb2
# import video_stream_pb2_grpc

# def generate_frames():
#     cap = cv2.VideoCapture(0)
#     # while True:
#     while True:
#         ret, frame = cap.read()
#         frame2 = cv2.imread("./car.jpg")
#         if not ret:
#             print("failed to grab")
#             # break
        
#         _, buffer = cv2.imencode('.jpg', frame)
#         _, buffer2 = cv2.imencode('.jpg', frame2)
#         print("encoded both")
#         yield video_stream_pb2.Frame(left=buffer2.tobytes(), right=buffer.tobytes())

# def run():
#     channel = grpc.insecure_channel('10.29.169.33:50051')
#     stub = video_stream_pb2_grpc.VideoStreamStub(channel)
#     # response = stub.Hello(video_stream_pb2.HelloRequest(greeting='ClientHere'))
#     # if response.reply:
#     #     print(f"connection established: {response.reply}")
#     # else:
#     #     print("failed to establish connection")
#     response = stub.SendFrame(generate_frames())
#     print("streamack message:", response.message)

# if __name__ == '__main__':
#     run()

import cv2
import grpc
import video_stream_pb2
import video_stream_pb2_grpc
from avp_stream import VisionProStreamer

def generate_frames():
    # avp_ip = '10.31.169.198'
    # s = VisionProStreamer(ip=avp_ip, record=True)
    cap = cv2.VideoCapture(0)
    resolution = (1280, 480)
    print(f"Resolution: {resolution}")
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, resolution[0])
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, resolution[1])

    while True:
        # r = s.latest
        # print(r['head'])

        ret, image = cap.read() # reads frame that has stereo images side by side
        # print('here')
        if not ret:
            print("failed to grab")
            break
        
        # split image in half
        w = image.shape[1]//2
        h = image.shape[0]
        im_left = image[:, :w]
        im_right = image[:, w:2*w]
        
        # cv2.imshow('test', image)
        # cv2.waitkey(1)
        _, buffer = cv2.imencode('.jpg', im_left)
        _, buffer2 = cv2.imencode('.jpg', im_right)
        yield video_stream_pb2.Frame(left=buffer.tobytes(), right=buffer2.tobytes())

def run():
    channel = grpc.insecure_channel('10.31.169.198:12345') # CHANGE TO VISION PRO IP
    stub = video_stream_pb2_grpc.VideoStreamStub(channel)
    response = stub.SendFrame(generate_frames())
    print("streamack message:", response.message)

if __name__ == '__main__':
    run()
    # generate_frames()
