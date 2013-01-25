//
//  Camera.hpp
//  InternetMap
//

#ifndef InternetMap_Camera_hpp
#define InternetMap_Camera_hpp

#include "Types.hpp"

/**
 a target contains all the data needed for the camera to sensibly focus on a node.
 */
struct Target {
    Vector3 vector; //where to aim the camera
    float zoom; //default zoom level
    float maxZoom; //max. user zoom level
    Target():vector(0, 0, 0), zoom(0.0f), maxZoom(0.0f) {}
};

/**
 the opengl camera for the view.
 has nice functions for targeting, animated zoom, rotation, etc.
 */
class Camera {
    float _displayWidth, _displayHeight;
    //TODO maybe target should be a Target?
    Vector3 _target;
    bool _isMovingToTarget;
    bool _allowIdleAnimation;
    
    Matrix4 _modelViewProjectionMatrix;
    Matrix4 _modelViewMatrix;
    Matrix4 _projectionMatrix;
    
    Matrix4 _rotationMatrix;
    float _rotation;
    float _zoom;
    float _maxZoom; //based on target node, because big nodes look ugly close up.
    
    TimeInterval _targetMoveStartTime;
    Vector3 _targetMoveStartPosition;
    
    float _zoomStart;
    float _zoomTarget;
    TimeInterval _zoomStartTime;
    TimeInterval _zoomDuration;
    
    TimeInterval _updateTime;
    TimeInterval _idleStartTime; // For "attract" mode
    
    Vector2 _panVelocity;
    TimeInterval _panEndTime;
    
    float _zoomVelocity;
    TimeInterval _zoomEndTime;
    
    float _rotationVelocity;
    TimeInterval _rotationEndTime;
    
    Quaternion _rotationStart;
    Quaternion _rotationTarget;
    TimeInterval _rotationStartTime;
    TimeInterval _rotationDuration;
    
    float _subregionX, _subregionY, _subregionWidth, _subregionHeight;
    
    void handleIdleMovement(TimeInterval delta);
    void handleMomentumPan(TimeInterval delta);
    void handleMomentumZoom(TimeInterval delta);
    void handleMomentumRotation(TimeInterval delta);
    Vector3 calculateMoveTarget(TimeInterval delta);
    void handleAnimatedZoom(TimeInterval delta);
    void handleAnimatedRotation(TimeInterval delta);
    void setRotationAndRenormalize(const Matrix4& matrix);
    
public:
    Camera();
    
    void setTarget(const Target& target);
    Vector3 target(void) { return _target; }
    void setDisplaySize(float width, float height) { _displayWidth = width; _displayHeight = height; }
    float displayWidth() { return _displayWidth; }
    float displayHeight() { return _displayHeight; }
    bool isMovingToTarget(void) { return _isMovingToTarget; }
    void setAllowIdleAnimation(bool b) { _allowIdleAnimation = b; }

    void rotateRadiansX(float rotate);
    void rotateRadiansY(float rotate);
    void rotateRadiansZ(float rotate);
    void rotateAnimated(Matrix4 rotation, TimeInterval duration);
    void zoomAnimated(float zoom, TimeInterval duration);
    void zoomByScale(float zoom);
    void resetIdleTimer(void);
    
    void update(TimeInterval currentTime);

    Matrix4 currentModelViewProjection(void);
    Matrix4 currentModelView(void);
    Matrix4 currentProjection(void);
    float currentZoom(void);

    Vector3 applyModelViewToPoint(Vector2 point);
    Vector3 cameraInObjectSpace(void);

    void startMomentumPanWithVelocity(Vector2 velocity);
    void stopMomentumPan();
    
    void startMomentumZoomWithVelocity(float velocity);
    void stopMomentumZoom();
    
    void startMomentumRotationWithVelocity(float velocity);
    void stopMomentumRotation();

    // set the subregion to render for a high resolution screenshot.
    // All numbers are normalized (so 0,0,1,1 would be fullscreen)
    void setViewSubregion(float x, float y, float w, float h);
    float getSubregionScale(void);

};

#endif
