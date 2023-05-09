//
//  Timer.hpp
//  RayTracing
//
//  Created by Willy Tai on 5/9/23.
//

#ifndef Timer_hpp
#define Timer_hpp

#include <chrono>


/* 8 bytes, just pass by value */
class TimeStep
{
public:
    TimeStep(const std::chrono::high_resolution_clock::duration& duration);

    float s() const;
    float ms() const;
    float operator()() const;

    template<typename T>
    friend T& operator<<(T& os, const TimeStep& duration) {
        os << duration.ms() << " ms";
        return os;
    }

private:
    std::chrono::high_resolution_clock::duration _timeStep;
};

class Timer
{
public:
    Timer();

    TimeStep deltaTime();
    void reset();

private:
    std::chrono::high_resolution_clock::time_point _lastTimePoint;
};

#endif /* Timer_hpp */
