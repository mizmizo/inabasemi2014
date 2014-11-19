#!/usr/bin/env roseus

(load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2w-interface.l")
(hrp2w-init)
(objects *hrp2w*)

;(ros::roseus "catch_tray")

(send *hrp2w* :reset-manip-pose)


(defun catch_tray nil
  (send *hrp2w* :angle-vector #f(0.0 30.0 0.0 40.0 -40.0 -11.2069 21.3581 -47.4988 -16.7953 -8.56676 -10.0 60.0 -40.0 7.10763 -14.7149 -47.2796 9.23729 6.70872 -10.0 -60.0))

;(send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
)

(defun up_tray nil
(setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
(setq *larm-end* (send *hrp2w* :larm :end-coords :copy-worldcoords))
(send *rarm-end* :translate (float-vector -100 0 100))
(send *larm-end* :translate (float-vector -100 0 100))
(send *hrp2w* :torso :waist-r joint-angle 0)
(send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis t :torso t)
(send *hrp2w* :larm :inverse-kinematics *larm-end* :rotation-axis t :torso t)

;(send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
)

;(send *rarm-end* :locate (send *rtarget* :pos) :world)
;(send *larm-end* :locate (send *ltarget* :pos) :world)

;持つときの経由点のangle-vector

;持つときのangle-vector
;#f(0.0 30.0 0.0 40.0 -40.0 -11.2069 21.3581 -47.4988 -16.7953 -8.56676 -10.0 60.0 -40.0 7.10763 -14.7149 -47.2796 9.23729 6.70872 -10.0 -60.0)

;trayのpos
;(setq *tray* (make-cube 30 50 3))
;#f(550.0 0.0 600.0)