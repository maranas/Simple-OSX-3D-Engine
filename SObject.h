//
//  SObject.h
//  RC-sim
//
//  Created by Moises Anthony Aranas on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GLUT/glut.h>
#import "obj.h"
#import "quaternions.h"

@interface SObject : NSObject {
	GLfloat pitch;
	GLfloat yaw;
	GLfloat roll;
	GLfloat global_roll;
	GLfloat global_pitch;
	GLfloat global_yaw;
	GLfloat x, y, z;
	struct quaternion Qtot;
	struct objModel objectMesh;
}

@property GLfloat pitch;
@property GLfloat yaw;
@property GLfloat roll;
@property GLfloat global_roll;
@property GLfloat global_pitch;
@property GLfloat global_yaw;
@property GLfloat x;
@property GLfloat y;
@property GLfloat z;

- (id) initWithModel:(NSString*) objModel withTexture:(NSString*) imgPath;
- (void) drawModel;
- (void) copyQtot: (struct quaternion*) Qcopy;
- (struct quaternion*) getQtot;

@end
