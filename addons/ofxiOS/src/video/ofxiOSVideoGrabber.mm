#if defined  __arm__

#include "ofxiOSVideoGrabber.h"
#include "AVFoundationVideoGrabber.h"

ofxiOSVideoGrabber::ofxiOSVideoGrabber() {
	grabber = shared_ptr<AVFoundationVideoGrabber>(new AVFoundationVideoGrabber());
}

ofxiOSVideoGrabber::~ofxiOSVideoGrabber() {
    //
}

//--------------------------------------------------------------
vector <ofVideoDevice> ofxiOSVideoGrabber::listDevices() const {
	return grabber->listDevices();
}

bool ofxiOSVideoGrabber::setup(int w, int h) {
    return grabber->initGrabber(w, h);
}

float ofxiOSVideoGrabber::getHeight() const {
	return grabber->getHeight();
}

float ofxiOSVideoGrabber::getWidth() const {
	return grabber->getWidth();
}

ofTexture * ofxiOSVideoGrabber::getTexturePtr() {
    return NULL;
}

void ofxiOSVideoGrabber::setVerbose(bool bTalkToMe) {
    ofLogWarning("ofxiOSVideoGrabber") << "setVerbose() is not implemented";
}

void ofxiOSVideoGrabber::setDeviceID(int deviceID) {
    grabber->setDevice(deviceID);
}

void ofxiOSVideoGrabber::setDesiredFrameRate(int framerate) {
    grabber->setCaptureRate(framerate);
}

void ofxiOSVideoGrabber::videoSettings() {
    ofLogWarning("ofxiOSVideoGrabber") << "videoSettings() is not implemented";
}

//--------------------------------------------------------------
bool ofxiOSVideoGrabber::isFrameNew() const {
	return grabber->isFrameNew();
}

void ofxiOSVideoGrabber::close() {
    ofLogWarning("ofxiOSVideoGrabber") << "close() is not implemented";
}

bool ofxiOSVideoGrabber::isInitialized() const{
    return grabber->isInitialized();
}

bool ofxiOSVideoGrabber::setPixelFormat(ofPixelFormat internalPixelFormat) {
	return grabber->setPixelFormat(internalPixelFormat);
}

ofPixelFormat ofxiOSVideoGrabber::getPixelFormat() const {
    return grabber->getPixelFormat();
}

//--------------------------------------------------------------
ofPixels & ofxiOSVideoGrabber::getPixels() {
    return pixels;
}

const ofPixels & ofxiOSVideoGrabber::getPixels() const {
    return getPixels();
}

//--------------------------------------------------------------
void ofxiOSVideoGrabber::update() {
	grabber->update();
    
    if(grabber->isFrameNew() == true) {
        pixels.setFromPixels(grabber->getPixels(),
                             getWidth(),
                             getHeight(),
                             grabber->getPixelFormat());
    }
}

//-------------------------------------------------------------- DEPRECATED.
bool ofxiOSVideoGrabber::initGrabber(int w, int h) {
    ofLogWarning("ofxiOSVideoGrabber") << "initGrabber(int w, int h) is deprecated, use setup(int w, int h) instead.";
    return setup(w, h);
}

void ofxiOSVideoGrabber::getDeviceList() const {
    ofLogWarning("ofxiOSVideoGrabber") << "getDeviceList() is deprecated, use listDevices() instead.";
};

ofPixels& ofxiOSVideoGrabber::getPixelsRef(){
	return getPixels();
}

const ofPixels& ofxiOSVideoGrabber::getPixelsRef() const{
	return getPixels();
}

#endif
