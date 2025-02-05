/*
 *  ofLight.cpp
 *  openFrameworksLib
 *
 *  Created by Memo Akten on 14/01/2011.
 *  Copyright 2011 MSA Visuals Ltd. All rights reserved.
 *
 */


#include "ofLight.h"
#include "ofConstants.h"
#include "ofLog.h"
#include "ofUtils.h"
#include <map>

static ofFloatColor globalAmbient(0.2, 0.2, 0.2, 1.0);

//----------------------------------------
void ofEnableLighting() {
	ofGetGLRenderer()->enableLighting();
}

//----------------------------------------
void ofDisableLighting() {
	ofGetGLRenderer()->disableLighting();
}

//----------------------------------------
void ofEnableSeparateSpecularLight(){
	ofGetGLRenderer()->enableSeparateSpecularLight();
}

//----------------------------------------
void ofDisableSeparateSpecularLight(){
    ofGetGLRenderer()->disableSeparateSpecularLight();
}

//----------------------------------------
bool ofGetLightingEnabled() {
	return ofGetGLRenderer()->getLightingEnabled();
}

//----------------------------------------
void ofSetSmoothLighting(bool b) {
	ofGetGLRenderer()->setSmoothLighting(b);
}

//----------------------------------------
void ofSetGlobalAmbientColor(const ofFloatColor& c) {
	ofGetGLRenderer()->setGlobalAmbientColor(c);
	globalAmbient = c;
}

const ofFloatColor & ofGetGlobalAmbientColor(){
	return globalAmbient;
}

//----------------------------------------
vector<weak_ptr<ofLight::Data> > & ofLightsData(){
	static vector<weak_ptr<ofLight::Data> > * lightsActive = ofIsGLProgrammableRenderer()?new vector<weak_ptr<ofLight::Data> >:new vector<weak_ptr<ofLight::Data> >(8);
	return *lightsActive;
}

ofLight::Data::Data(){
	glIndex			= -1;
	isEnabled		= false;
	attenuation_constant = 0.000001;
	attenuation_linear = 0.000001;
	attenuation_quadratic = 0.000001;
	spotCutOff = 45;
	exponent = 16;
	width = 1;
	height = 1;
	lightType = OF_LIGHT_POINT;
}

ofLight::Data::~Data(){
	if(glIndex==-1) return;
	ofGetGLRenderer()->setLightAmbientColor(glIndex,ofColor(0,0,0,255));
	ofGetGLRenderer()->setLightDiffuseColor(glIndex,ofColor(0,0,0,255));
	ofGetGLRenderer()->setLightSpecularColor(glIndex,ofColor(0,0,0,255));
	ofGetGLRenderer()->setLightPosition(glIndex,ofVec4f(0,0,1,0));
	ofGetGLRenderer()->disableLight(glIndex);
}

//----------------------------------------
ofLight::ofLight()
:data(new Data){
    setAmbientColor(ofColor(0,0,0));
    setDiffuseColor(ofColor(255,255,255));
    setSpecularColor(ofColor(255,255,255));
	setPointLight();
    
    // assume default attenuation factors //
    setAttenuation(1.f,0.f,0.f);
}

//----------------------------------------
void ofLight::setup() {
    if(data->glIndex==-1){
		bool bLightFound = false;
		// search for the first free block
		for(size_t i=0; i<ofLightsData().size(); i++) {
			if(ofLightsData()[i].expired()) {
				data->glIndex = i;
				data->isEnabled = true;
				ofLightsData()[i] = data;
				bLightFound = true;
				break;
			}
		}
		if(!bLightFound && ofIsGLProgrammableRenderer()){
			ofLightsData().push_back(data);
			data->glIndex = ofLightsData().size() - 1;
			data->isEnabled = true;
			bLightFound = true;
		}
		if( bLightFound ){
            // run this the first time, since it was not found before //
            onPositionChanged();
            setAmbientColor( getAmbientColor() );
            setDiffuseColor( getDiffuseColor() );
            setSpecularColor( getSpecularColor() );
            setAttenuation( getAttenuationConstant(), getAttenuationLinear(), getAttenuationQuadratic() );
            if(getIsSpotlight()) {
                setSpotlightCutOff(getSpotlightCutOff());
                setSpotConcentration(getSpotConcentration());
            }
            if(getIsSpotlight() || getIsDirectional()) {
                onOrientationChanged();
            }
        }else{
        	ofLogError("ofLight") << "setup(): couldn't get active GL light, maximum number of "<< ofLightsData().size() << " reached";
        }
	}
}

//----------------------------------------
void ofLight::enable() {
    setup();
	data->isEnabled = true;
    onPositionChanged(); // update the position //
	onOrientationChanged();
	ofGetGLRenderer()->enableLight(data->glIndex);
}

//----------------------------------------
void ofLight::disable() {
	data->isEnabled = false;
	ofGetGLRenderer()->disableLight(data->glIndex);
}

//----------------------------------------
int ofLight::getLightID() const{
	return data->glIndex;
}

//----------------------------------------
bool ofLight::getIsEnabled() const {
	return data->isEnabled;
}

//----------------------------------------
void ofLight::setDirectional() {
	data->lightType	= OF_LIGHT_DIRECTIONAL;
}

//----------------------------------------
bool ofLight::getIsDirectional() const {
	return data->lightType == OF_LIGHT_DIRECTIONAL;
}

//----------------------------------------
void ofLight::setSpotlight(float spotCutOff, float exponent) {
	data->lightType		= OF_LIGHT_SPOT;
	setSpotlightCutOff( spotCutOff );
	setSpotConcentration( exponent );
}

//----------------------------------------
bool ofLight::getIsSpotlight() const{
	return data->lightType == OF_LIGHT_SPOT;
}

//----------------------------------------
void ofLight::setSpotlightCutOff( float spotCutOff ) {
    data->spotCutOff = CLAMP(spotCutOff, 0, 90);
    ofGetGLRenderer()->setLightSpotlightCutOff(data->glIndex, spotCutOff);
}

//----------------------------------------
float ofLight::getSpotlightCutOff() const{
    if(!getIsSpotlight()) {
        ofLogWarning("ofLight") << "getSpotlightCutOff(): light " << data->glIndex << " is not a spot light";
    }
    return data->spotCutOff;
}

//----------------------------------------
void ofLight::setSpotConcentration( float exponent ) {
    data->exponent = CLAMP(exponent, 0, 128);
	ofGetGLRenderer()->setLightSpotConcentration(data->glIndex, exponent);
}

//----------------------------------------
float ofLight::getSpotConcentration() const{
    if(!getIsSpotlight()) {
        ofLogWarning("ofLight") << "getSpotConcentration(): light " << data->glIndex << " is not a spot light";
    }
    return data->exponent;
}

//----------------------------------------
void ofLight::setPointLight() {
	data->lightType	= OF_LIGHT_POINT;
}

//----------------------------------------
bool ofLight::getIsPointLight() const{
	return data->lightType == OF_LIGHT_POINT;
}

//----------------------------------------
void ofLight::setAttenuation( float constant, float linear, float quadratic ) {
    // falloff = 0 -> 1, 0 being least amount of fallof, 1.0 being most //
	data->attenuation_constant    = constant;
	data->attenuation_linear      = linear;
	data->attenuation_quadratic   = quadratic;

    ofGetGLRenderer()->setLightAttenuation(data->glIndex, constant, linear, quadratic);
}

//----------------------------------------
float ofLight::getAttenuationConstant() const{
    return data->attenuation_constant;
}

//----------------------------------------
float ofLight::getAttenuationLinear() const{
    return data->attenuation_linear;
}

//----------------------------------------
float ofLight::getAttenuationQuadratic() const{
    return data->attenuation_quadratic;
}

void ofLight::setAreaLight(float width, float height){
	data->lightType = OF_LIGHT_AREA;
	data->width = width;
	data->height = height;
}

bool ofLight::getIsAreaLight() const{
	return data->lightType == OF_LIGHT_AREA;
}

//----------------------------------------
int ofLight::getType() const{
	return data->lightType;
}

//----------------------------------------
void ofLight::setAmbientColor(const ofFloatColor& c) {
	data->ambientColor = c;
	ofGetGLRenderer()->setLightAmbientColor(data->glIndex, c);
}

//----------------------------------------
void ofLight::setDiffuseColor(const ofFloatColor& c) {
	data->diffuseColor = c;
	ofGetGLRenderer()->setLightDiffuseColor(data->glIndex, c);
}

//----------------------------------------
void ofLight::setSpecularColor(const ofFloatColor& c) {
	data->specularColor = c;
	ofGetGLRenderer()->setLightSpecularColor(data->glIndex, c);
}

//----------------------------------------
ofFloatColor ofLight::getAmbientColor() const {
	return data->ambientColor;
}

//----------------------------------------
ofFloatColor ofLight::getDiffuseColor() const {
	return data->diffuseColor;
}

//----------------------------------------
ofFloatColor ofLight::getSpecularColor() const {
	return data->specularColor;
}

//----------------------------------------
void ofLight::customDraw(){
    if(getIsPointLight()) {
        ofDrawSphere( 0,0,0, 10);
    } else if (getIsSpotlight()) {
        float coneHeight = (sin(data->spotCutOff*DEG_TO_RAD) * 30.f) + 1;
        float coneRadius = (cos(data->spotCutOff*DEG_TO_RAD) * 30.f) + 8;
		ofPushMatrix();
		ofRotate(-90, 1, 0, 0);
		ofDrawCone(0, -(coneHeight*.5), 0, coneHeight, coneRadius);
		ofPopMatrix();
    } else  if (getIsAreaLight()) {
		ofPushMatrix();
		ofDrawPlane(data->width,data->height);
		ofPopMatrix();
    }else{
        ofDrawBox(10);
    }
    ofDrawAxis(20);
}


//----------------------------------------
void ofLight::onPositionChanged() {
	if(data->glIndex==-1) return;
	// if we are a positional light and not directional, update light position
	if(getIsSpotlight() || getIsPointLight() || getIsAreaLight()) {
		data->position = ofVec4f(getGlobalPosition().x,getGlobalPosition().y,getGlobalPosition().z,1);
		ofGetGLRenderer()->setLightPosition(data->glIndex,data->position);
	}
}

//----------------------------------------
void ofLight::onOrientationChanged() {
	if(data->glIndex==-1) return;
	// if we are a directional light and not positional, update light position (direction)
	if(getIsDirectional()) {
		// (tig) takes into account global orientation should node be parented.
		ofVec3f lookAtDir = ( getGlobalTransformMatrix().getInverse() * ofVec4f(0,0,-1, 1) ).getNormalized();
		data->position = ofVec4f(lookAtDir.x,lookAtDir.y,lookAtDir.z,0);
		ofGetGLRenderer()->setLightPosition(data->glIndex,data->position);
	}else if(getIsSpotlight() || getIsAreaLight()) {
		// determines the axis of the cone light //

		// (tig) takes into account global orientation should node be parented.
		ofVec3f lookAtDir = ( getGlobalTransformMatrix().getInverse() * ofVec4f(0,0,-1, 1) ).getNormalized();
		data->direction = ofVec3f(lookAtDir.x,lookAtDir.y,lookAtDir.z);
		ofGetGLRenderer()->setLightSpotDirection(data->glIndex,data->direction);
	}
	if(getIsAreaLight()){
		data->up = getUpDir();
		data->right = getXAxis();
	}
}
