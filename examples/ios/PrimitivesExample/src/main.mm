#include "ofMain.h"
#include "ofAppiOSWindow.h"
#include "ofApp.h"

int main() {
    
    //  here are the most commonly used iOS window settings.
    //------------------------------------------------------
    ofAppiOSWindow::Settings settings;
    settings.enableRetina = false; // enables retina resolution if the device supports it.
    settings.enableDepth = true; // enables depth buffer for 3d drawing.
    settings.enableAntiAliasing = false; // enables anti-aliasing which smooths out graphics on the screen.
    settings.numOfAntiAliasingSamples = 0; // number of samples used for anti-aliasing.
    settings.enableHardwareOrientation = false; // enables native view orientation.
    settings.enableHardwareOrientationAnimation = false; // enables native orientation changes to be animated.
    settings.rendererType = OFXIOS_RENDERER_ES1; // type of renderer to use, ES1, ES2, etc.
    
    ofAppiOSWindow window(settings);
    
	ofSetupOpenGL(&window, 0, 0, OF_FULLSCREEN);
    
	ofRunApp(new ofApp);
}
