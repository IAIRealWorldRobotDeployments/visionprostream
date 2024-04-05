import cv2
import grpc
import video_stream_pb2
import video_stream_pb2_grpc
import numpy as np
from threading import Thread
import numpy as np
import pyrealsense2 as rs
import rclpy
from rclpy.node import Node 
from sensor_msgs.msg import Image
from cv_bridge import CvBridge

class StereoStreamROS(Node):
    def __init__(self, src=0, resolution=(640,480), name="StereoVideoStream"):

        # initialize the thread name
        self.name = name
        super().__init__(self.name)
        self.image_capture_time = super().get_clock().now().to_msg()
        self.publisher = self.create_publisher(Image, self.name , 1)
        self.bridge=CvBridge()
        # initialize the variable used to indicate if the thread should
        # be stopped
        self.stopped = False

    def start(self):
        # start the thread to read frames from the video stream
        t = Thread(target=self.update, name=self.name, args=())
        t.daemon = True
        t.start()
        return self

    def update(self):
        # keep looping infinitely until the thread is stopped
        pass
        # while True:
        #     # if the thread indicator variable is set, stop the thread
        #     if self.stopped:
        #         return

        #     # otherwise, read the next frame from the stream
        #     (self.grabbed, self.frame) = self.stream.read()
        #     self.image_capture_time = super().get_clock().now().to_msg()

    def read(self):
        # return the frame most recently read
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
            self.publish(im_left) #TODO: also publish im_right
            yield video_stream_pb2.Frame(left=buffer.tobytes(), right=buffer2.tobytes())

    def publish(self, image):
        image.header.stamp = self.image_capture_time
        self.publisher.publish(image)
    def stop(self):
        # indicate that the thread should be stopped
        self.stopped = True
        
def run():
    vr_stream = StereoStreamROS().start()
    channel = grpc.insecure_channel('128.31.33.110:50051')
    stub = video_stream_pb2_grpc.VideoStreamStub(channel)
    response = stub.SendFrame(vr_stream.read())
    print("streamack message:", response.message)

if __name__ == '__main__':
    rclpy.init()
    run()
    rclpy.shutdown()
#    generate_frames()
