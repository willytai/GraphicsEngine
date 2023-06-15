//
//  GeometryObj.hpp
//  RayTracing
//
//  Created by Willy Tai on 5/26/23.
//

#ifndef GeometryObj_hpp
#define GeometryObj_hpp

#include <vector>
#include <simd/simd.h>
#include "../Shader/VertexType.hpp"


enum class GeometryIndexType : uint8_t
{
    UInt16,
    UInt32,
};

/// 1. Geometries should be generated using the word space coordinate system (right-handed coordinate system).
/// 2. We are enabling back face culling on geometries for better rendering performance. Since front face winding
///    is set to counter-clockwise, make sure the indices are also generated this way.
class GeometryObj
{
protected:
    using RawIndexType = uint16_t;

public:
    GeometryObj() = default;
    virtual ~GeometryObj() = default;
    
    virtual       uint32_t                          indexCount()    const { return (uint32_t)_indices.size(); }
    virtual       uint32_t                          indexTypeSize() const { return sizeof(RawIndexType); }
    virtual       GeometryIndexType                 indexType()     const { return GeometryIndexType::UInt16; }
    virtual const std::vector<RawIndexType>&        indices()       const { return _indices; }
    virtual const std::vector<VtxPositionType>&     positions()     const { return _positions; }
    virtual const std::vector<VtxNormalType>&       normals()       const { return _normals; }
    
protected:
    std::vector<VtxPositionType>    _positions;
    std::vector<VtxNormalType>      _normals;
    std::vector<RawIndexType>       _indices;
};

#endif /* GeometryObj_hpp */
