#pragma once

#include "ofMain.h"

#include "ofxOsc.h"

#define HOST "localhost"
#define PORT 12345

class ofApp : public ofBaseApp{
    
public:
    void setup();
    void update();
    void draw();
    
    void keyPressed(int key);
    void keyReleased(int key);
    void mouseMoved(int x, int y );
    void mouseDragged(int x, int y, int button);
    void mousePressed(int x, int y, int button);
    void mouseReleased(int x, int y, int button);
    void mouseEntered(int x, int y);
    void mouseExited(int x, int y);
    void windowResized(int w, int h);
    void dragEvent(ofDragInfo dragInfo);
    void gotMessage(ofMessage msg);
    
    ofPolyline line;
    
    vector<ofPolyline> lines;
    ofFbo fbo;
    
    ofImage erase_btn;
    ofImage apply_btn;
    
    ofPoint erase_offset;
    ofPoint apply_offset;
    
    ofPoint button_dimensions;
    
    vector<ofPoint> signature;
    
    ofxOscSender sender;
    
    
    
    
    
};
