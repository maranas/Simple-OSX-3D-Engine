//
//  SObject.m
//  RC-sim
//
//  Created by Moises Anthony Aranas on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SObject.h"


@implementation SObject

@synthesize pitch;
@synthesize yaw;
@synthesize roll;
@synthesize global_roll;
@synthesize global_pitch;
@synthesize global_yaw;
@synthesize x;
@synthesize y;
@synthesize z;

- (id) initWithModel:(NSString*) objModel withTexture:(NSString*) imgPath
{
	if( (self=[super init] )) {
		loadModel(objModel, &objectMesh, imgPath);
		roll = 0; pitch = 0; yaw = 0;
		global_pitch = 0; global_yaw = 0; global_roll = 0;
		Qtot.w = 1; Qtot.x = 0; Qtot.y = 0; Qtot.z = 0;
	}
	return self;
}

- (void) drawModel
{
	drawModel(&objectMesh);
	
	// this updates the model's euler angle vlaues
	quatToEuler(&Qtot, &global_pitch, &global_yaw, &global_roll);
}

- (void) copyQtot: (struct quaternion*) Qcopy
{
	Qcopy->w = Qtot.w;
	Qcopy->x = Qtot.x;
	Qcopy->y = Qtot.y;
	Qcopy->z = Qtot.z;
}

- (struct quaternion*) getQtot
{
	return &Qtot;
}

@end
