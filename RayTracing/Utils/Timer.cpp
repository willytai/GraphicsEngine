//
//  Timer.cpp
//  RayTracing
//
//  Created by Willy Tai on 5/9/23.
//

#include "Timer.hpp"


TimeStep::TimeStep(const std::chrono::high_resolution_clock::duration& duration) {
    _timeStep = duration;
}

float TimeStep::s() const {
    return (float)_timeStep.count()*1e-9f;
}

float TimeStep::ms() const {
    return (float)_timeStep.count()*1e-6f;
}

float TimeStep::operator()() const {
    return this->s();
}

Timer::Timer() {
    this->reset();
}

TimeStep Timer::deltaTime() {
    auto now = std::chrono::high_resolution_clock::now();
    auto ret = now - _lastTimePoint;
    _lastTimePoint = now;
    return ret;
}

void Timer::reset() {
    _lastTimePoint = std::chrono::high_resolution_clock::now();
}
