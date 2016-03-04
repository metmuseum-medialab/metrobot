#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    ofBackground(255);
    ofClear(255,255,255, 0);
    fbo.allocate(ofGetWidth(), ofGetHeight(),GL_RGBA);
    ofEnableAlphaBlending();
    //fbo.clear();
    fbo.begin();
     ofClear(255,255,255, 0);
    fbo.end();
    
    erase_btn.load("erase.png");
    apply_btn.load("apply.png");
    
    erase_offset=ofPoint(20,20);
    apply_offset=ofPoint(20,80);
    
    button_dimensions=ofPoint(120,50);
    
    sender.setup(HOST, PORT);
    
}

//--------------------------------------------------------------
void ofApp::update(){

}

//--------------------------------------------------------------
void ofApp::draw(){

    
    
    
    ofMesh meshy;
    meshy.setMode(OF_PRIMITIVE_TRIANGLE_STRIP);
    
    
    float widthSmooth = 0.01;
    float angleSmooth;
    
    for (int i = 0;  i < line.getVertices().size(); i++){
        
        
        int me_m_one = i-1;
        int me_p_one = i+1;
        if (me_m_one < 0) me_m_one = 0;
        if (me_p_one ==  line.getVertices().size()) me_p_one =  line.getVertices().size()-1;
        
        ofPoint diff = line.getVertices()[me_p_one] - line.getVertices()[me_m_one];
        float angle = atan2(diff.y, diff.x);
        
        if (i == 0) angleSmooth = angle;
        else {
            
            angleSmooth = ofLerpDegrees(angleSmooth, angle, 1.0);
            
        }
        
        
        float dist = diff.length();
        
        float w = ofMap(dist, 10, 20, 5, 20, true);
        
        widthSmooth = 0.9f * widthSmooth + 0.1f * w;
        
        ofPoint offset;
        offset.x = cos(angleSmooth + PI/2) * widthSmooth;
        offset.y = sin(angleSmooth + PI/2) * widthSmooth;
        
        
        
        meshy.addVertex(  line.getVertices()[i] +  offset );
        meshy.addVertex(  line.getVertices()[i] -  offset );
        
        
        
    }
     ofSetColor(255);
    fbo.begin();
    
    ofSetColor(0,0,0);
    meshy.draw();
    ofSetColor(100,100,100);
  //  meshy.drawWireframe();
    fbo.end();
    
    
    ofSetColor(255);
    fbo.draw(0,0);
    
    
    
    
    //interface
    
    
    ofSetColor(255);

    erase_btn.draw(erase_offset.x, erase_offset.y, button_dimensions.x, button_dimensions.y);
    apply_btn.draw(apply_offset.x, apply_offset.y, button_dimensions.x, button_dimensions.y);
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){

}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){
line.addVertex(ofPoint(x,y));
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
// line.clear();
    
    if(x>erase_offset.x&&x<erase_offset.x+button_dimensions.x){

        if(y>erase_offset.y&&y<erase_offset.y+button_dimensions.y){
            fbo.begin();
            ofClear(255,255,255, 0);
            fbo.end();
        }

    }
    
    if(x>apply_offset.x&&x<apply_offset.x+button_dimensions.x){
        
        if(y>apply_offset.y&&y<apply_offset.y+button_dimensions.y){
            fbo.begin();
            ofClear(255,255,255, 0);
            fbo.end();
            
            
            // send data
            
            ofxOscMessage m;
            m.setAddress("/test");
            
            m.addStringArg("hello");
            m.addFloatArg(ofGetElapsedTimef());
            m.addStringArg("msg_start");
            m.addStringArg("new_line");
            for (int i = 0;  i < signature.size(); i++){
                cout<<signature[i].x<<" "<<signature[i].y<<" "<<signature[i].z<<endl;
                 m.addStringArg("["+ofToString(signature[i].x)+","+ofToString(signature[i].y)+","+ofToString(signature[i].z)+"]");
                if(signature[i].x==-1) m.addStringArg("new_line");
              
            }
            m.addStringArg("msg_end");
            
            sender.sendMessage(m, false);
            
            
        }
        
    }
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){
    
    
    for (int i = 0;  i < line.getVertices().size(); i++){
        
        
        int me_m_one = i-1;
        int me_p_one = i+1;
        if (me_m_one < 0) me_m_one = 0;
        if (me_p_one ==  line.getVertices().size()) me_p_one =  line.getVertices().size()-1;
        
        ofPoint diff = line.getVertices()[me_p_one] - line.getVertices()[me_m_one];
        
        float dist = diff.length();
        
        float w = ofMap(dist, 10, 20, 5, 20, true);
        
        
        signature.push_back(ofPoint(line.getVertices()[i].x/ofGetWidth(),line.getVertices()[i].y/ofGetHeight(),(w-5)/15) );
        
    }
    
    signature.push_back(ofPoint(-1,-1,-1) );
    
    
    
    for (int i = 0;  i < signature.size(); i++){
        cout<<signature[i].x<<" "<<signature[i].y<<" "<<signature[i].z<<endl;
    }
     line= ofPolyline();
  //  lines.push_back(line);
   
    
}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y){

}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}
