#!/usr/bin/env roseus

(ros::roseus "joy_mop")
(ros::advertise "/cmd_vel" geometry_msgs::Twist 1)

(setq *vel_msg* (instance geometry_msgs::Twist :init))

(load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2w-interface.l")
(hrp2w-init)
(objects *hrp2w*)
(setq *tfl* (instance ros::transform-listener :init))


(defun ready_pose ()
  (send *hrp2w* :reset-pose)
  (send *hrp2w* :head :neck-p :joint-angle 30)
  (send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  )


(defun catch_mop ()
  ;;targetting                                               
  ;;rarm 
  (setq *torso-co* (send (car (send *hrp2w* :torso)) :copy-worldcoords))
  (send *tfl* :wait-for-transform "CHEST_LINK0"
        "/camera_remote/depth_registered/cluster_decomposeroutput00"
        (ros::time 0) 3)
  (setq *tarr* (send *tfl* :lookup-transform "CHEST_LINK0"
        "/camera_remote/depth_registered/cluster_decomposeroutput00"
	(ros::time 0)))
  (setq *torso-co-copy* (send *torso-co* :copy-worldcoords))
  (setq *tarr-copy* (send *tarr* :copy-worldcoords))
  (setq *ik-rtarget* (send *torso-co* :transform *tarr*))
  (setq *ik-rtarget-pre* (send *torso-co-copy* :transform *tarr-copy*))
  (send *ik-rtarget-pre* :translate #f(-150 -70 0) :world)
  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (send *rarm-end* :locate (send *ik-rtarget-pre* :pos) :world)
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
	:debug-view t :torso t :link-list (send *hrp2w* :link-list (send
    *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))
  (send *hrp2w* :rarm :thumb-r :joint-angle 45)
  (send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)

  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (send *rarm-end* :locate (send *ik-rtarget* :pos) :world)
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
   :debug-view t :torso t :link-list (send *hrp2w* :link-list (send
   *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))
  (send *hrp2w* :rarm :thumb-r :joint-angle 45)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (hrp2w-start-grasp :rarm)

  ;;one hand                                                                                         
  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (send *rarm-end* :translate #f(-50 -50 200) :world)
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
   :debug-view t :torso t :link-list (send *hrp2w* :link-list (send
   *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  ;;rarm up                                                    
  (send *hrp2w* :rarm :angle-vector #f(-40 -18 60 -64 -35 40 -14 0))
  (send *hrp2w* :torso :angle-vector #f(0 0))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  ;;larm left sweep
  (send *hrp2w* :larm :angle-vector #f(-55 35 -51 -92 80 -26 24 -45))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (send *hrp2w* :larm :angle-vector #f(-72 24 -60 -87 80 -24 13 -45))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (send *ri* :start-impedance :larm)
  (hrp2w-start-grasp :larm)
  )


(defun sweep ()
  ;;ready                                                       
  (send *hrp2w* :rarm :angle-vector #f(-40 -13 72 -46 -30 35 -29 0))
  (send *hrp2w* :larm :angle-vector #f(-60 26 -60 -90 65 -24 13 0))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  ;;left sweep                                                  
  (send *hrp2w* :larm :angle-vector #f(-55 35 -51 -92 80 -26 24 0))
  (send *hrp2w* :rarm :angle-vector #f(-45 5 72 -26 -25 35 -30 0))
  (send *hrp2w* :torso :angle-vector #f(15 0))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  ;;ready                                                       
  (send *hrp2w* :rarm :angle-vector #f(-40 -13 72 -46 -30 35 -29 0))
  (send *hrp2w* :larm :angle-vector #f(-60 26 -60 -90 65 -24 13 0))
  (send *hrp2w* :torso :angle-vector #f(0 0))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  ;;right sweep
  (send *hrp2w* :rarm :angle-vector #f(-28 -31 51 -60 -25 28 -29 0))
  (send *hrp2w* :larm :angle-vector #f(-75 -3 -70 -60 65 -24 13 0))
  (send *hrp2w* :torso :angle-vector #f(-15 0))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)     
  ;;up                                                          
  (send *hrp2w* :larm :angle-vector #f(-72 24 -60 -87 80 -24 13 0))
  (send *hrp2w* :rarm :angle-vector #f(-40 -18 60 -64 -35 40 -14 0))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  )


(defun return_mop ()
  ;;ready
  (send *hrp2w* :rarm :angle-vector #f(-40 -13 72 -46 -30 35 -29 15))
  (send *hrp2w* :larm :angle-vector #f(-60 26 -60 -90 65 -24 13 -15))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (hrp2w-stop-grasp :larm)
  (send *hrp2w* :larm :thumb-r :joint-angle -45)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 3000)
  (send *ri* :wait-interpolation)
  (send *hrp2w* :larm :angle-vector #f(-55 35 -51 -92 80 -26 24 -45))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 3000)
  (send *ri* :wait-interpolation)
  (send *ri* :stop-impedance :larm)
  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (send *rarm-end* :locate (send *ik-rtarget-rtn* :pos) :world)
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
   :debug-view t :torso t :link-list (send *hrp2w* :link-list (send
   *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (hrp2w-stop-grasp :rarm)

  )


(defun cmd_callback (msg)
  (format t "axes: ~A~%" (send msg :axes))
  (format t "buttons: ~A~%" (send msg :buttons))
  (setq buttons (send msg :buttons))
  (setq axes (send msg :axes))
  (if (= (elt buttons 10) 1)
      (progn
	(setq x (* (elt axes 1) 0.1))
	(setq y (* (elt axes 0) 0.1))
	(setq z (* (elt axes 2) 0.1))
	(cond
	 ((= (elt buttons 3) 1)
	  (progn
	    (setq x 0)
	    (setq y 0)
	    (setq z 0)
	    (ready_pose)
	    ))
	 ((= (elt buttons 13) 1)
	  (progn
	    (setq x 0)
	    (setq y 0)
	    (setq z 0)
	    (catch_mop)
	    ))
	 ((= (elt buttons 12) 1)
	  (progn
	    (setq x 0)
	    (setq y 0)
	    (setq z 0)
	    (sweep)
	    ))
	 ((= (elt buttons 14) 1)
	  (progn
	    (setq x 0)
	    (setq y 0)
	    (setq z 0)
	    (return_mop)
	    ))
	 )
	)
    (progn
      (setq x 0)
      (setq y 0)
      (setq z 0)
      )
    )
  (send *vel_msg* :linear :x x)
  (send *vel_msg* :linear :y y)
  (send *vel_msg* :angular :z z)
  (ros::publish "/cmd_vel" *vel_msg*)
  )

(ros::subscribe "/joy" sensor_msgs::Joy #'cmd_callback)

(do-until-key
 (ros::spin-once)
 (ros::publish "/cmd_vel" *vel_msg*)
 )