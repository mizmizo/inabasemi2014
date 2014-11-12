#!/usr/bin/env roseus

(ros::roseus "tutorial_joy")

(defun joy-callback (msg)
  (format t "axes: ~A~%" (send msg :axes))
  (format t "buttons: ~A~%" (send msg :buttons))
  )
(ros::subscribe "/joy" sensor_msgs::Joy #'joy-callback)

(do-until-key
 (ros::spin-once)
 )
