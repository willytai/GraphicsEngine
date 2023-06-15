//
//  Icosphere.hpp
//  RayTracing
//
//  Created by Willy Tai on 5/26/23.
//

#ifndef Icosphere_hpp
#define Icosphere_hpp

#include <unordered_map>
#include <unordered_set>
#include "GeometryObj.hpp"
#include "../../Utils/Common.hpp"

class Icosphere : public GeometryObj
{
public:
    Icosphere(float radius, int subdivisions);
    virtual ~Icosphere() = default;
    
    static Ref<Icosphere> Create(float radius, int subdivisions);

    float   radius()      const { return _radius; }
    int     subdivision() const { return _subdivisions; }

private:
    void    generateNextSubdivision();
    
private:
    float   _radius;
    int     _subdivisions;

    // some constants for generating icospheres
    inline static const float H_ANGLE_RAD = 360.0f / 5.0f * M_PI / 180.0f;
    inline static const float V_ANGLE_RAD = atanf(0.5f);



#ifdef TEST
public:
    struct TestData
    {
        std::unordered_map<RawIndexType, int>   indexAccessFrequency;
        std::unordered_set<RawIndexType>        indexSub0;
    } testData;
#endif

};

#endif /* Icosphere_hpp */
