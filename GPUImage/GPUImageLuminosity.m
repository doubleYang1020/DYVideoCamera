#import "GPUImageLuminosity.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageInitialLuminosityFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 uniform sampler2D inputImageTexture;
 
 varying highp vec2 outputTextureCoordinate;
 
 varying highp vec2 upperLeftInputTextureCoordinate;
 varying highp vec2 upperRightInputTextureCoordinate;
 varying highp vec2 lowerLeftInputTextureCoordinate;
 varying highp vec2 lowerRightInputTextureCoordinate;
 
 const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

 void main()
 {
     highp float upperLeftLuminance = dot(texture2D(inputImageTexture, upperLeftInputTextureCoordinate).rgb, W);
     highp float upperRightLuminance = dot(texture2D(inputImageTexture, upperRightInputTextureCoordinate).rgb, W);
     highp float lowerLeftLuminance = dot(texture2D(inputImageTexture, lowerLeftInputTextureCoordinate).rgb, W);
     highp float lowerRightLuminance = dot(texture2D(inputImageTexture, lowerRightInputTextureCoordinate).rgb, W);

     highp float luminosity = 0.25 * (upperLeftLuminance + upperRightLuminance + lowerLeftLuminance + lowerRightLuminance);
     gl_FragColor = vec4(luminosity, luminosity, luminosity, 1.0);
 }
);

NSString *const kGPUImageLuminosityFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 uniform sampler2D inputImageTexture;
 
 varying highp vec2 outputTextureCoordinate;
 
 varying highp vec2 upperLeftInputTextureCoordinate;
 varying highp vec2 upperRightInputTextureCoordinate;
 varying highp vec2 lowerLeftInputTextureCoordinate;
 varying highp vec2 lowerRightInputTextureCoordinate;
 
 void main()
 {
     highp float upperLeftLuminance = texture2D(inputImageTexture, upperLeftInputTextureCoordinate).r;
     highp float upperRightLuminance = texture2D(inputImageTexture, upperRightInputTextureCoordinate).r;
     highp float lowerLeftLuminance = texture2D(inputImageTexture, lowerLeftInputTextureCoordinate).r;
     highp float lowerRightLuminance = texture2D(inputImageTexture, lowerRightInputTextureCoordinate).r;
     
     highp float luminosity = 0.25 * (upperLeftLuminance + upperRightLuminance + lowerLeftLuminance + lowerRightLuminance);
     gl_FragColor = vec4(luminosity, luminosity, luminosity, 1.0);
 }
);
#else
NSString *const kGPUImageInitialLuminosityFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 varying vec2 outputTextureCoordinate;
 
 varying vec2 upperLeftInputTextureCoordinate;
 varying vec2 upperRightInputTextureCoordinate;
 varying vec2 lowerLeftInputTextureCoordinate;
 varying vec2 lowerRightInputTextureCoordinate;
 
 const vec3 W = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     float upperLeftLuminance = dot(texture2D(inputImageTexture, upperLeftInputTextureCoordinate).rgb, W);
     float upperRightLuminance = dot(texture2D(inputImageTexture, upperRightInputTextureCoordinate).rgb, W);
     float lowerLeftLuminance = dot(texture2D(inputImageTexture, lowerLeftInputTextureCoordinate).rgb, W);
     float lowerRightLuminance = dot(texture2D(inputImageTexture, lowerRightInputTextureCoordinate).rgb, W);
     
     float luminosity = 0.25 * (upperLeftLuminance + upperRightLuminance + lowerLeftLuminance + lowerRightLuminance);
     gl_FragColor = vec4(luminosity, luminosity, luminosity, 1.0);
 }
);

NSString *const kGPUImageLuminosityFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 varying vec2 outputTextureCoordinate;
 
 varying vec2 upperLeftInputTextureCoordinate;
 varying vec2 upperRightInputTextureCoordinate;
 varying vec2 lowerLeftInputTextureCoordinate;
 varying vec2 lowerRightInputTextureCoordinate;
 
 void main()
 {
     float upperLeftLuminance = texture2D(inputImageTexture, upperLeftInputTextureCoordinate).r;
     float upperRightLuminance = texture2D(inputImageTexture, upperRightInputTextureCoordinate).r;
     float lowerLeftLuminance = texture2D(inputImageTexture, lowerLeftInputTextureCoordinate).r;
     float lowerRightLuminance = texture2D(inputImageTexture, lowerRightInputTextureCoordinate).r;
     
     float luminosity = 0.25 * (upperLeftLuminance + upperRightLuminance + lowerLeftLuminance + lowerRightLuminance);
     gl_FragColor = vec4(luminosity, luminosity, luminosity, 1.0);
 }
);
#endif

@implementation GPUImageLuminosity

@synthesize luminosityProcessingFinishedBlock = _luminosityProcessingFinishedBlock;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithVertexShaderFromString:kGPUImageColorAveragingVertexShaderString fragmentShaderFromString:kGPUImageInitialLuminosityFragmentShaderString]))
    {
        return nil;
    }
    
    texelWidthUniform = [filterProgram uniformIndex:@"texelWidth"];
    texelHeightUniform = [filterProgram uniformIndex:@"texelHeight"];
        
    __unsafe_unretained GPUImageLuminosity *weakSelf = self;
    [self setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime frameTime) {
        [weakSelf extractLuminosityAtFrameTime:frameTime];
    }];

    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        secondFilterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageColorAveragingVertexShaderString fragmentShaderString:kGPUImageLuminosityFragmentShaderString];
        
        if (!secondFilterProgram.initialized)
        {
            [self initializeSecondaryAttributes];
            
            if (![secondFilterProgram link])
            {
                NSString *progLog = [secondFilterProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [secondFilterProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [secondFilterProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                filterProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        secondFilterPositionAttribute = [secondFilterProgram attributeIndex:@"position"];
        secondFilterTextureCoordinateAttribute = [secondFilterProgram attributeIndex:@"inputTextureCoordinate"];
        secondFilterInputTextureUniform = [secondFilterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        secondFilterInputTextureUniform2 = [secondFilterProgram uniformIndex:@"inputImageTexture2"]; // This does assume a name of "inputImageTexture2" for second input texture in the fragment shader
        
        secondFilterTexelWidthUniform = [secondFilterProgram uniformIndex:@"texelWidth"];
        secondFilterTexelHeightUniform = [secondFilterProgram uniformIndex:@"texelHeight"];

        [GPUImageContext setActiveShaderProgram:secondFilterProgram];
        
        glEnableVertexAttribArray(secondFilterPositionAttribute);
        glEnableVertexAttribArray(secondFilterTextureCoordinateAttribute);
    });

    return self;
}

- (void)initializeSecondaryAttributes;
{
    [secondFilterProgram addAttribute:@"position"];
	[secondFilterProgram addAttribute:@"inputTextureCoordinate"];
}


#pragma mark -
#pragma mark Callbacks

- (void)extractLuminosityAtFrameTime:(CMTime)frameTime;
{
    runSynchronouslyOnVideoProcessingQueue(^{

        // we need a normal color texture for this filter
        NSAssert(self.outputTextureOptions.internalFormat == GL_RGBA, @"The output texture format for this filter must be GL_RGBA.");
        NSAssert(self.outputTextureOptions.type == GL_UNSIGNED_BYTE, @"The type of the output texture of this filter must be GL_UNSIGNED_BYTE.");
        
        NSUInteger totalNumberOfPixels = round(finalStageSize.width * finalStageSize.height);
        
        if (rawImagePixels == NULL)
        {
            rawImagePixels = (GLubyte *)malloc(totalNumberOfPixels * 4);
        }
        
        [GPUImageContext useImageProcessingContext];
        [outputFramebuffer activateFramebuffer];

        glReadPixels(0, 0, (int)finalStageSize.width, (int)finalStageSize.height, GL_RGBA, GL_UNSIGNED_BYTE, rawImagePixels);
        
        NSUInteger luminanceTotal = 0;
        NSUInteger byteIndex = 0;
        for (NSUInteger currentPixel = 0; currentPixel < totalNumberOfPixels; currentPixel++)
        {
            luminanceTotal += rawImagePixels[byteIndex];
            byteIndex += 4;
        }
        
        CGFloat normalizedLuminosityTotal = (CGFloat)luminanceTotal / (CGFloat)totalNumberOfPixels / 255.0;
        
        if (_luminosityProcessingFinishedBlock != NULL)
        {
            _luminosityProcessingFinishedBlock(normalizedLuminosityTotal, frameTime);
        }
    });
}


@end
