/****************************************************************************/
// Eclipse SUMO, Simulation of Urban MObility; see https://eclipse.org/sumo
// Copyright (C) 2013-2023 German Aerospace Center (DLR) and others.
// This program and the accompanying materials are made available under the
// terms of the Eclipse Public License 2.0 which is available at
// https://www.eclipse.org/legal/epl-2.0/
// This Source Code may also be made available under the following Secondary
// Licenses when the conditions for such availability set forth in the Eclipse
// Public License 2.0 are satisfied: GNU General Public License, version 2
// or later which is available at
// https://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
// SPDX-License-Identifier: EPL-2.0 OR GPL-2.0-or-later
/****************************************************************************/
/// @file    PollutantsInterface.cpp
/// @author  Daniel Krajzewicz
/// @author  Michael Behrisch
/// @date    Mon, 19.08.2013
///
// Interface to capsulate different emission models
/****************************************************************************/
#include <limits>
#include <cmath>

#include "HelpersHBEFA4.h"
#include "PollutantsInterface.h"


// ===========================================================================
// static definitions
// ===========================================================================
const double PollutantsInterface::Helper::ZERO_SPEED_ACCURACY = .5;
HelpersHBEFA4 PollutantsInterface::myHBEFA4Helper;
PollutantsInterface::Helper* PollutantsInterface::myHelpers[] = {
    &PollutantsInterface::myHBEFA4Helper
};
std::vector<std::string> PollutantsInterface::myAllClassesStr;


// ===========================================================================
// method definitions
// ===========================================================================

// ---------------------------------------------------------------------------
// PollutantsInterface::Emissions - methods
// ---------------------------------------------------------------------------

PollutantsInterface::Emissions::Emissions(double co2, double co, double hc, double f, double nox, double pmx, double elec) :
    CO2(co2),
    CO(co),
    HC(hc),
    fuel(f),
    NOx(nox),
    PMx(pmx),
    electricity(elec) {
}


void PollutantsInterface::Emissions::addScaled(const Emissions& a, const double scale) {
    CO2 += scale * a.CO2;
    CO += scale * a.CO;
    HC += scale * a.HC;
    fuel += scale * a.fuel;
    NOx += scale * a.NOx;
    PMx += scale * a.PMx;
    electricity += scale * a.electricity;
}

// ---------------------------------------------------------------------------
// PollutantsInterface::Helper - methods
// ---------------------------------------------------------------------------

PollutantsInterface::Helper::Helper(std::string name, const int baseIndex, const int defaultClass) :
    myName(name),
    myBaseIndex(baseIndex) {
    if (defaultClass != -1) {
        myEmissionClassStrings.insert("default", defaultClass);
        myEmissionClassStrings.addAlias("unknown", defaultClass);
    }
}


const
std::string& PollutantsInterface::Helper::getName() const {
    return myName;
}


SUMOEmissionClass
PollutantsInterface::Helper::getClassByName(const std::string& eClass, const SUMOVehicleClass vc) {
    if (myEmissionClassStrings.hasString(eClass)) {
        return myEmissionClassStrings.get(eClass);
    }
    std::string eClassLower = eClass;
    std::transform(eClassLower.begin(), eClassLower.end(), eClassLower.begin(),
            [](unsigned char c){ return std::tolower(c); });
    return myEmissionClassStrings.get(eClassLower);
}


const std::string
PollutantsInterface::Helper::getClassName(const SUMOEmissionClass c) const {
    return myName + "/" + myEmissionClassStrings.getString(c);
}


bool
PollutantsInterface::Helper::isSilent(const SUMOEmissionClass c) {
    return (c & (int)0xffffffff & ~HEAVY_BIT) == 0;
}


SUMOEmissionClass
PollutantsInterface::Helper::getClass(const SUMOEmissionClass base, const std::string& vClass, const std::string& fuel, const std::string& eClass, const double weight) const {
    return base;
}


std::string
PollutantsInterface::Helper::getAmitranVehicleClass(const SUMOEmissionClass c) const {
    return "Passenger";
}


std::string
PollutantsInterface::Helper::getFuel(const SUMOEmissionClass c) const {
    return "Gasoline";
}


int
PollutantsInterface::Helper::getEuroClass(const SUMOEmissionClass c) const {
    return 0;
}


double
PollutantsInterface::Helper::getWeight(const SUMOEmissionClass c) const {
    return -1.;
}


double
PollutantsInterface::Helper::compute(const SUMOEmissionClass c, const EmissionType e, const double v, const double a, const double slope) const {
    return 0.;
}


double
PollutantsInterface::Helper::getModifiedAccel(const SUMOEmissionClass c, const double v, const double a, const double slope) const {
    return a;
}


void
PollutantsInterface::Helper::addAllClassesInto(std::vector<SUMOEmissionClass>& list) const {
    myEmissionClassStrings.addKeysInto(list);
}


bool
PollutantsInterface::Helper::includesClass(const SUMOEmissionClass c) const {
    return (c >> 16) == (myBaseIndex >> 16);
}

// ---------------------------------------------------------------------------
// PollutantsInterface - methods
// ---------------------------------------------------------------------------

SUMOEmissionClass
PollutantsInterface::getClassByName(const std::string& eClass, const SUMOVehicleClass vc) {
    const std::string::size_type sep = eClass.find("/");
    const std::string model = eClass.substr(0, sep); // this includes the case of no separator
    for (int i = 0; i < 1; i++) {
        if (myHelpers[i]->getName() == model) {
            if (sep != std::string::npos) {
                const std::string subClass = eClass.substr(sep + 1);
                return myHelpers[i]->getClassByName(subClass, vc);
            }
            return myHelpers[i]->getClassByName("default", vc);
        }
    }
    throw InvalidArgument("Unknown emission class '" + eClass + "'.");
}


const std::vector<SUMOEmissionClass>
PollutantsInterface::getAllClasses() {
    std::vector<SUMOEmissionClass> result;
    for (int i = 0; i < 8; i++) {
        myHelpers[i]->addAllClassesInto(result);
    }
    return result;
}


const std::vector<std::string>&
PollutantsInterface::getAllClassesStr() {
    // first check if myAllClassesStr has to be filled
    if (myAllClassesStr.empty()) {
        // first obtain all emissionClasses
        std::vector<SUMOEmissionClass> emissionClasses;
        for (int i = 0; i < 8; i++) {
            myHelpers[i]->addAllClassesInto(emissionClasses);
        }
        // now write all emissionClasses in myAllClassesStr
        for (const auto& i : emissionClasses) {
            myAllClassesStr.push_back(getName(i));
        }
    }
    return myAllClassesStr;
}

std::string
PollutantsInterface::getName(const SUMOEmissionClass c) {
    return myHelpers[c >> 16]->getClassName(c);
}


std::string
PollutantsInterface::getPollutantName(const EmissionType e) {
    switch (e) {
        case CO2:
            return "CO2";
        case CO:
            return "CO";
        case HC:
            return "HC";
        case FUEL:
            return "fuel";
        case NO_X:
            return "NOx";
        case PM_X:
            return "PMx";
        case ELEC:
            return "electricity";
        default:
            throw InvalidArgument("Unknown emission type");
    }
}

bool
PollutantsInterface::isHeavy(const SUMOEmissionClass c) {
    return (c & HEAVY_BIT) != 0;
}


bool
PollutantsInterface::isSilent(const SUMOEmissionClass c) {
    return myHelpers[c >> 16]->isSilent(c);
}


SUMOEmissionClass
PollutantsInterface::getClass(const SUMOEmissionClass base, const std::string& vClass,
                              const std::string& fuel, const std::string& eClass, const double weight) {
    return myHelpers[base >> 16]->getClass(base, vClass, fuel, eClass, weight);
}


std::string
PollutantsInterface::getAmitranVehicleClass(const SUMOEmissionClass c) {
    return myHelpers[c >> 16]->getAmitranVehicleClass(c);
}


std::string
PollutantsInterface::getFuel(const SUMOEmissionClass c) {
    return myHelpers[c >> 16]->getFuel(c);
}


int
PollutantsInterface::getEuroClass(const SUMOEmissionClass c) {
    return myHelpers[c >> 16]->getEuroClass(c);
}


double
PollutantsInterface::getWeight(const SUMOEmissionClass c) {
    return myHelpers[c >> 16]->getWeight(c);
}


double
PollutantsInterface::compute(const SUMOEmissionClass c, const EmissionType e, const double v, const double a, const double slope) {
    return myHelpers[c >> 16]->compute(c, e, v, a, slope);
}


PollutantsInterface::Emissions
PollutantsInterface::computeAll(const SUMOEmissionClass c, const double v, const double a, const double slope) {
    const Helper* const h = myHelpers[c >> 16];
    return Emissions(h->compute(c, CO2, v, a, slope), h->compute(c, CO, v, a, slope), h->compute(c, HC, v, a, slope),
                     h->compute(c, FUEL, v, a, slope), h->compute(c, NO_X, v, a, slope), h->compute(c, PM_X, v, a, slope),
                     h->compute(c, ELEC, v, a, slope));
}


double
PollutantsInterface::computeDefault(const SUMOEmissionClass c, const EmissionType e, const double v, const double a, const double slope, const double tt) {
    const Helper* const h = myHelpers[c >> 16];
    return (h->compute(c, e, v, 0, slope) + h->compute(c, e, v - a, a, slope)) * tt / 2.;
}


double
PollutantsInterface::getModifiedAccel(const SUMOEmissionClass c, const double v, const double a, const double slope) {
    return myHelpers[c >> 16]->getModifiedAccel(c, v, a, slope);
}


/****************************************************************************/
