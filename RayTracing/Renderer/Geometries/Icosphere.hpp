//
//  Icosphere.hpp
//  RayTracing
//
//  Created by Willy Tai on 5/26/23.
//

#ifndef Icosphere_hpp
#define Icosphere_hpp

#include "GeometryObj.hpp"
#include "../../Utils/Common.hpp"

class Icosphere : public GeometryObj
{
public:
    Icosphere(float radius, int subdivisions);
    virtual ~Icosphere() = default;
    
    static Ref<Icosphere> Create(float radius, int subdivisions);
    
private:
    float   _radius;
    int     _subdivisions;

    // some constants for generating icospheres
    inline static const float H_ANGLE_RAD = 360.0f / 5.0f * M_PI / 180.0f;
    inline static const float V_ANGLE_RAD = atanf(0.5f);
};

#endif /* Icosphere_hpp */
