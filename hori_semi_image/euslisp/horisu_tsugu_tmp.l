#!/usr/bin/env roseus


(load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2w-interface.l")
(hrp2w-init)
(objects (list *hrp2w*))
;;(ros::roseus "horisu_tsugu")
(ros::roseus-add-msgs "jsk_pcl_ros")

(ros::roseus "horisu_ninshiki")
(setq *tfl* (instance ros::transform-listener :init))

(defun boxes-callback (msg)
  (setq *boxg* msg))

(ros::subscribe "/camera_remote/depth_registered/cluster_decomposer/boxes" jsk_pcl_ros::BoundingBoxArray #'boxes-callback)



(setq *boxg* nil)




(defun kamae ()
  (let (rthumb lthumb)
    (setq rthumb (send *hrp2w* :rarm :thumb-r :joint-angle))
    (setq lthumb (send *hrp2w* :larm :thumb-r :joint-angle))
    (send *hrp2w* :reset-pose)
    (send *hrp2w* :rarm :thumb-r :joint-angle rthumb)
    (send *hrp2w* :rarm :thumb-r :joint-angle rthumb)
    (send *irtviewer* :draw-objects)
    (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
    (send *ri* :wait-interpolation)

     ;;
    (setq *larm-end* (send *hrp2w* :larm :end-coords :copy-worldcoords))
    (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))

    (send *larm-end* :translate #f(100 -200 -100) :world)
    (send *larm-end* :rpy -45 0 0)

    (send *hrp2w* :larm :inverse-kinematics *larm-end* :rotation-axis t
	  :debug-view t :torso t
	  :link-list (cdr (cdr (send *hrp2w* :link-list (send *hrp2w* :larm :end-coords :parent) (car (send *hrp2w* :torso :links))))))

    (send *hrp2w* :head :look-at (send *hrp2w* :larm :end-coords :pos))

    (send *irtviewer* :draw-objects)
    (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
    (send *ri* :wait-interpolation)
    ;;
    (setq *rarm-end* (send *larm-end* :copy-worldcoords))
    (send *rarm-end* :translate #f(100 -300 0) :world)
    (send *rarm-end* :rpy 45 0 0)

    (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis t
	  :debug-view t :torso t
	  :link-list (cdr (cdr (send *hrp2w* :link-list (send *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))))
    (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
    (send *ri* :wait-interpolation)
    ))

(defun tsugu ()

  ;;(setq *cap-end* (send *hrp2w* :larm :end-coords :copy-worldcoords))
  ;;(send *cap-end* :locate #f(0 0 100) :world)

  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (send *rarm-end* :locate (send *hrp2w* :larm :end-coords :worldpos) :world)
  (send *rarm-end* :translate #f(0 0 300) :world)
  (send *rarm-end* :translate (float-vector 0 (* (- 200) (sin (deg2rad 45))) (* (- 200) (cos (deg2rad 45)))) :world)
  (send *rarm-end* :rotate -45 :x :world)
;;
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis t
	:debug-view t :torso t
	:link-list (cdr (cdr (send *hrp2w* :link-list (send *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))))
  (send *irtviewer* :draw-objects)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)

;;  (send *rarm-end* :locate (send *hrp2w* :larm :end-coords :worldpos) :world)
;;  (send *rarm-end* :translate #f(0 0 400) :world)
;;  (send *rarm-end* :translate (float-vector 0 (* (- 200) (sin (deg2rad 30))) (* (- 200) (cos (deg2rad 30)))) :world)
;;  (send *rarm-end* :rotate -30 :x :world)

;;  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis t
;;	:debug-view t :torso t
;;	:link-list (cdr (cdr (send *hrp2w* :link-list (send *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))))
;;  (send *irtviewer* :draw-objects)
;;  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
;;  (send *ri* :wait-interpolation)
;;

;;  (send *rarm-end* :locate (send *hrp2w* :larm :end-coords :worldpos) :world)
;;  (send *rarm-end* :translate #f(0 0 400) :world)
;;  (send *rarm-end* :translate (float-vector 0 (* (- 200) (sin (deg2rad 15))) (* (- 200) (cos (deg2rad 15)))) :world)
;;  (send *rarm-end* :rotate -15 :x :world)

;;  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis t
;;	:debug-view t :torso t
;;	:link-list (cdr (cdr (send *hrp2w* :link-list (send *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))))
;;  (send *irtviewer* :draw-objects)
;;  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
;;  (send *ri* :wait-interpolation)
)


(defun find-my ()
  (let (volume index count volume-tmp)
    (if *boxg*
	(progn
	  (setq volume 0)
	  (setq index 0)
	  (setq count 0)
	  (format t "if 1")
	  (dolist (box (send *boxg* :boxes))
	    (progn
	      (if (> (setq volume-tmp (* (send box :dimensions :x) (send box :dimensions :y) (send box :dimensions :z))) volume)
		  (progn
		    (setq volume volume-tmp)
		    (setq index count))
		(setq index (+ count 1)))))

	  (setq *torso-co* (send (car (send *hrp2w* :torso)) :copy-worldcoords))
	  (if (send *tfl* :wait-for-transform "CHEST_LINK0"
		    (format nil "/camera_remote/depth_registered/cluster_decomposeroutput~0,2d" index)
		    (ros::time 0) 3)
	      (progn
		(setq *target-co* (send *tfl* :lookup-transform "CHEST_LINK0"
					(format nil "/camera_remote/depth_registered/cluster_decomposeroutput~0,2d" index)
					(ros::time 0)))


		(setq *ik-target* (send *torso-co* :transform *target-co*))

		'done)
	    nil))
      nil)))








(defun tsukamur (pet)


  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))

  (send *rarm-end* :locate pet :world)
  (send *rarm-end* :translate #f(-150 0 50) :world)

  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis :x
	:debug-view t :torso t :link-list (send *hrp2w* :link-list (send
								    *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))




  (send *irtviewer* :draw-objects)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  ;;

  (hrp2w-stop-grasp :rarm)
  ;;
  (send *rarm-end* :translate #f(50 0 0) :world)

  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis :x
	:debug-view t :torso t :link-list (send *hrp2w* :link-list (send
								    *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))

  (send *irtviewer* :draw-objects)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)

  (send *ri* start-grasp :rarm)
  )



(defun tsukamul (cup)


  (setq *larm-end* (send *hrp2w* :larm :end-coords :copy-worldcoords))

  (send *larm-end* :locate cup :world)
  (send *larm-end* :translate #(-100 0 100) :world)

  (send *hrp2w* :larm :inverse-kinematics *larm-end* :rotation-axis :x
	:debug-view t :torso t :link-list (send *hrp2w* :link-list (send
								    *hrp2w* :larm :end-coords :parent) (car (send *hrp2w* :torso :links))))

  (send *irtviewer* :draw-objects)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  ;;
  (hrp2w-stop-grasp :larm)
  ;;
  (send *larm-end* :translate #f(100 0 0) :world)

  (send *hrp2w* :larm :inverse-kinematics *larm-end* :rotation-axis :x
	:debug-view t :torso t :link-list (send *hrp2w* :link-list (send
								    *hrp2w* :larm :end-coords :parent) (car (send *hrp2w* :torso :links))))


  (send *irtviewer* :draw-objects)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)

  (send *ri* :start-grasp :larm)
  )


(defun reset_my ()
  (let (rthumb lthumb)
    (setq rthumb (send *hrp2w* :rarm :thumb-r :joint-angle))
    (setq lthumb (send *hrp2w* :larm :thumb-r :joint-angle))
    (send *hrp2w* :reset-pose)
    (send *hrp2w* :rarm :thumb-r :joint-angle rthumb)
    (send *hrp2w* :rarm :thumb-r :joint-angle rthumb)
    (send *hrp2w* :head :neck-p :joint-angle 20.0)
    (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)))

(defun tsukamu-rarm ()
  (tsukamur (send *ik-target* :pos)))

(defun tsukamu-larm ()
  (tsukamul (send *ik-target* :pos)))


(defun tsugu_tmp ()
  (reset-my)
  (ros::spin-once)
  (find-my)
  (tsukamur (send *ik-target* :pos) )
  ;;(send *rarm-end* :locate (send *ik-target* :pos) :world)

  ;;(find_my)
  ;;(tsukamul (send *ik-target* :pos) )
  ;;(send *rarm-end* :locate (send *ik-target* :pos) :world)
  (kamae)
  (tsugu)

(ros::spin-once)