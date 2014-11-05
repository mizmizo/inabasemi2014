#!/usr/bin/env roseus

(ros::roseus "tutorial_vmax")
(ros::advertise "/cmd_vel" geometry_msgs::Twist 1)

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
