#!/usr/bin/env roseus

(ros::roseus "tutorial_desuyo")

(setq *vel_msg* (instance geometry_msgs::Twist :init))



(defun cmd_vel (x y theta)
  (send *vel_msg* :linear :x x)
  (send *vel_msg* :linear :y y)
  (send *vel_msg* :angular :z theta)
  (ros::publish "/cmd_vel" *vel_msg*)
  )

(defun start-vmax ()
  (cmd_vel 0.05 0.0 0.0)
  (unix::usleep (* 1000 1000))
  (cmd_vel 0.0 0.0 0.0)
  )


(defun joy-callback (msg)
  (format t "axes: ~A~%" (send msg :axes))
  (format t "buttons: ~A~%" (send msg :buttons))
  (setq x  (/ (elt (send msg :axes) 1) 10))
  (setq th (/ (elt (send msg :axes) 2) 10))
  (cmd_vel (* x (elt (send msg :buttons) 10)) 0 (* th (elt (send msg :buttons) 10)))
  )


(ros::subscribe "/joy" sensor_msgs::Joy #'joy-callback)
(ros::advertise "/cmd_vel" geometry_msgs::Twist 1)

(do-until-key
 (ros::spin-once)
 )

(cmd_vel 0.0 0.0 0.0)
