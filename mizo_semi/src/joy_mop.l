#!/usr/bin/env roseus

(ros::roseus "joy_mop")
(ros::advertise "/cmd_vel" geometry_msgs::Twist 1)

(setq *vel_msg* (instance geometry_msgs::Twist :init))

(load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2w-interface.l")
(hrp2w-init)
(objects *hrp2w*)
(setq *tfl* (instance ros::transform-listener :init))

(setq def_x 0)
(setq def_y 0)
(setq def_z 0)
(setq odom_x 0)
(setq odom_y 0)
(setq odom_z 0)
(setq go_x 0)
(setq go_y 0)
(setq go_z 0)
(setq catch_1 0)


(defun ready_pose ()
  (send *hrp2w* :reset-pose)
  (send *hrp2w* :head :neck-p :joint-angle 30)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  )


(defun catch_mop ()
  (if (= catch_1 0)
      ;;targetting
      (progn
	(setq *torso-co* (send (car (send *hrp2w* :torso)) :copy-worldcoords))
	(send *tfl* :wait-for-transform "CHEST_LINK0"
	      "/camera_remote/depth_registered/cluster_decomposeroutput00"
	      (ros::time 0) 3)
	(setq *tarr* (send *tfl* :lookup-transform "CHEST_LINK0"
			   "/camera_remote/depth_registered/cluster_decomposeroutput00"
			   (ros::time 0)))
	(setq *torso-co-copy* (send *torso-co* :copy-worldcoords))
	(setq *tarr-copy* (send *tarr* :copy-worldcoords))
	(setq *torso-co-copy2* (send *torso-co* :copy-worldcoords))
	(setq *tarr-copy2* (send *tarr* :copy-worldcoords))
	(setq *ik-rtarget* (send *torso-co* :transform *tarr*))
	(setq *ik-rtarget-pre* (send *torso-co-copy* :transform *tarr-copy*))
	(setq *ik-rtarget-rtn* (send *torso-co-copy2* :transform *tarr-copy2*))
	(send *ik-rtarget-pre* :translate #f(-150 -70 0) :world)
	(setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
	(send *rarm-end* :locate (send *ik-rtarget-pre* :pos) :world)
	(send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
	      :debug-view t :torso t :link-list (send *hrp2w* :link-list (send *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))
	(send *hrp2w* :rarm :thumb-r :joint-angle 45)
	(send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
	(send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
	(send *ri* :wait-interpolation)

	(setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
	(send *rarm-end* :locate (send *ik-rtarget* :pos) :world)
	(send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
	      :debug-view t :torso t :link-list (send *hrp2w* :link-list (send *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))
	(send *hrp2w* :rarm :thumb-r :joint-angle 45)
	(send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
	(send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
	(send *ri* :wait-interpolation)
	(hrp2w-start-grasp :rarm :angle -10)

	;;one hand
	(setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
	(send *rarm-end* :translate #f(-50 -50 200) :world)
	(send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
	      :debug-view t :torso t :link-list (send *hrp2w* :link-list (send *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))
	(send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
	(send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
	(send *ri* :wait-interpolation)
	;;rarm up
	(send *hrp2w* :rarm :angle-vector #f(-40 -18 60 -64 -35 40 -14 0))
	(send *hrp2w* :torso :angle-vector #f(0 0))
	(send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
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
	(hrp2w-start-grasp :larm :angle 10)
	(setq catch_1 1)
	)
    nil
    )
  )


(defun sweep ()
  ;;ready
  (send *hrp2w* :rarm :angle-vector #f(-40 -13 72 -46 -30 35 -29 0))
  (send *hrp2w* :larm :angle-vector #f(-60 26 -60 -90 65 -24 13 0))
  (send *hrp2w* :torso :angle-vector #f(0 0))
  (send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  ;;left sweep
  (send *hrp2w* :larm :angle-vector #f(-55 35 -51 -92 80 -26 24 0))
  (send *hrp2w* :rarm :angle-vector #f(-45 5 72 -26 -25 35 -30 0))
  (send *hrp2w* :torso :angle-vector #f(15 0))
  (send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  ;;ready
  (send *hrp2w* :rarm :angle-vector #f(-40 -13 72 -46 -30 35 -29 0))
  (send *hrp2w* :larm :angle-vector #f(-60 26 -60 -90 65 -24 13 0))
  (send *hrp2w* :torso :angle-vector #f(0 0))
  (send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  ;;right sweep
  (send *hrp2w* :rarm :angle-vector #f(-28 -31 51 -60 -25 28 -29 0))
  (send *hrp2w* :larm :angle-vector #f(-75 -3 -70 -60 65 -24 13 0))
  (send *hrp2w* :torso :angle-vector #f(-15 0))
  (send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  ;;up
  (send *hrp2w* :larm :angle-vector #f(-72 24 -60 -87 80 -24 13 0))
  (send *hrp2w* :rarm :angle-vector #f(-40 -18 60 -64 -35 40 -14 0))
  (send *hrp2w* :torso :angle-vector #f(0 0))
  (send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  )


(defun down  ()
  ;;ready
  (send *hrp2w* :rarm :angle-vector #f(-40 -13 72 -46 -30 35 -29 0))
  (send *hrp2w* :larm :angle-vector #f(-60 26 -60 -90 65 -24 13 0))
  (send *hrp2w* :torso :angle-vector #f(0 0))
  (send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  )


(defun up ()
  ;;up
  (send *hrp2w* :larm :angle-vector #f(-72 24 -60 -87 80 -24 13 0))
  (send *hrp2w* :rarm :angle-vector #f(-40 -18 60 -64 -35 40 -14 0))
  (send *hrp2w* :torso :angle-vector #f(0 0))
  (send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  )


(defun return_mop ()
  ;;up
  (send *hrp2w* :larm :angle-vector #f(-72 24 -60 -87 80 -24 13 0))
  (send *hrp2w* :rarm :angle-vector #f(-40 -18 60 -64 -35 40 -14 0))
  (send *hrp2w* :torso :angle-vector #f(0 0))
  (send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
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
  (send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (hrp2w-stop-grasp :rarm)

  )

(defun culc_pos (msg)
  (if (= def_x 0)
      (progn    (setq def_x (send msg :pose :pose :position :x))
		(setq def_y (send msg :pose :pose :position :y))
		(setq def_z (send msg :pose :pose :orientation :z))
		)
    (progn    (setq odom_x (send msg :pose :pose :position :x))
	      (setq odom_y (send msg :pose :pose :position :y))
	      (setq odom_z (send msg :pose :pose :orientation :z))
	      )
    )
  (setq trans_x (- odom_x def_x))
  (setq trans_y (- odom_y def_y))
  (setq trans_z (- odom_z def_z))
  )


(defun return_pos ()
  (if (= go_x 0)
      (progn
        (setq go_x (* trans_x -1000))
        (setq go_y (* trans_y -1000))
        (setq go_z (* trans_z ))
        (format t "x:~A~%y:~A~%z:~A~%" go_x go_y go_z)
	(setq go_1 0)
        )
    (progn
      (if (= go_1 0)
	  (progn
	    (format t "x:~A~%y:~A~%z:~A~%" go_x go_y go_z)
	    (send *vmax* :go-pos-relative-unsafe go_x go_y go_z 10000)
	    (send *vmax* :wait-interpolation 15000)
	    (setq go_1 1)
	    )
	nil
	)
      )
    )
  )


(defun return_pos_reset ()
  (setq go_x 0)
  (setq go_y 0)
  (setq go_z 0)
  )


(defun cmd_callback (msg)
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
	    (format t "ready pose~%")
	    (ready_pose)
	    ))
	 ((= (elt buttons 13) 1)
	  (progn
	    (setq x 0)
	    (setq y 0)
	    (setq z 0)
	    (format t "catch~%")
	    (catch_mop)
	    ))
	 ((= (elt buttons 12) 1)
	  (progn
	    (setq x 0)
	    (setq y 0)
	    (setq z 0)
	    (format t "sweep~%")
	    (sweep)
	    ))
	 ((= (elt buttons 14) 1)
	  (progn
	    (setq x 0)
	    (setq y 0)
	    (setq z 0)
	    (format t "return mop~%")
	    (return_mop)
	    ))
	 ((= (elt buttons 4) 1)
	  (progn
	    (setq x 0)
	    (setq y 0)
	    (setq z 0)
	    (format t "up~%")
	    (up)
	    ))
	 ((= (elt buttons 6) 1)
	  (progn
	    (setq x 0)
	    (setq y 0)
	    (setq z 0)
	    (format t "down~%")
	    (down)
	    ))
	 ((= (elt buttons 0) 1)
	  (progn
	    (setq x 0)
	    (setq y 0)
	    (setq z 0)
	    (format t "return pos~%")
	    (return_pos)
	    ))
	 ((= (elt buttons 0) 1)
	  (progn
	    (setq x 0)
	    (setq y 0)
	    (setq z 0)
	    (format t "retuen pos~%")
	    (return_pos_reset)
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
(ros::subscribe "/odom_vmax" nav_msgs::Odometry #'culc_pos)

(do-until-key
 (ros::spin-once)
 (ros::publish "/cmd_vel" *vel_msg*)
 )