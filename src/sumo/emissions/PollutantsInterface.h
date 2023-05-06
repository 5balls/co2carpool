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
/// @file    PollutantsInterface.h
/// @author  Daniel Krajzewicz
/// @author  Michael Behrisch
/// @date    Mon, 19.08.2013
///
// Interface to capsulate different emission models
/****************************************************************************/
#pragma once

#include <vector>
#include <limits>
#include <cmath>
#include <algorithm>
#include <string>
#include "StringBijection.h"


// ===========================================================================
// class declarations
// ===========================================================================
class HelpersHBEFA4;
typedef int SUMOEmissionClass;

/**
 * @enum SUMOVehicleClass
 * @brief Definition of vehicle classes to differ between different lane usage and authority types
 *
 * Bits:
 * @arg 0-7:  vehicle ownership
 * @arg 8-23: vehicle size
 *
 * From NavTeq:
 * @arg [0] All
 * @arg [1] Passenger cars
 * @arg [2] High Occupancy Vehicle
 * @arg [3] Emergency Vehicle
 * @arg [4] Taxi
 * @arg [5] Public Bus
 * @arg [6] Delivery Truck
 * @arg [7] Transport Truck
 * @arg [8] Bicycle
 * @arg [9] Pedestrian
 */
enum SUMOVehicleClass {
    /// @brief vehicles ignoring classes
    SVC_IGNORING = 0,

    /// @name vehicle ownership
    //@{

    /// @brief private vehicles
    SVC_PRIVATE = 1,
    /// @brief public emergency vehicles
    SVC_EMERGENCY = 1 << 1,
    /// @brief authorities vehicles
    SVC_AUTHORITY = 1 << 2,
    /// @brief army vehicles
    SVC_ARMY = 1 << 3,
    /// @brief vip vehicles
    SVC_VIP = 1 << 4,
    //@}


    /// @name vehicle size
    //@{
    /// @brief pedestrian
    SVC_PEDESTRIAN = 1 << 5,

    /// @brief vehicle is a passenger car (a "normal" car)
    SVC_PASSENGER = 1 << 6,
    /// @brief vehicle is a HOV
    SVC_HOV = 1 << 7,
    /// @brief vehicle is a taxi
    SVC_TAXI = 1 << 8,
    /// @brief vehicle is a bus
    SVC_BUS = 1 << 9,
    /// @brief vehicle is a coach
    SVC_COACH = 1 << 10,
    /// @brief vehicle is a small delivery vehicle
    SVC_DELIVERY = 1 << 11,
    /// @brief vehicle is a large transport vehicle
    SVC_TRUCK = 1 << 12,
    /// @brief vehicle is a large transport vehicle
    SVC_TRAILER = 1 << 13,
    /// @brief vehicle is a motorcycle
    SVC_MOTORCYCLE = 1 << 14,
    /// @brief vehicle is a moped
    SVC_MOPED = 1 << 15,
    /// @brief vehicle is a bicycle
    SVC_BICYCLE = 1 << 16,
    /// @brief is an electric vehicle
    SVC_E_VEHICLE = 1 << 17,

    /// @brief vehicle is a light rail
    SVC_TRAM = 1 << 18,
    /// @brief vehicle is a city rail
    SVC_RAIL_URBAN = 1 << 19,
    /// @brief vehicle is a not electrified rail
    SVC_RAIL = 1 << 20,
    /// @brief rail vehicle that requires electrified tracks
    SVC_RAIL_ELECTRIC = 1 << 21,
    /// @brief vehicle that is allowed to drive on high-speed rail tracks
    SVC_RAIL_FAST = 1 << 22,

    /// @brief is an arbitrary ship
    SVC_SHIP = 1 << 23,

    /// @brief is a user-defined type
    SVC_CUSTOM1 = 1 << 24,
    /// @brief is a user-defined type
    SVC_CUSTOM2 = 1 << 25,
    //@}

    /// @brief classes which drive on tracks
    SVC_RAIL_CLASSES = SVC_RAIL_ELECTRIC | SVC_RAIL_FAST | SVC_RAIL | SVC_RAIL_URBAN | SVC_TRAM,
    /// @brief public transport
    SVC_PUBLIC_CLASSES = SVC_BUS | SVC_RAIL_CLASSES,
    /// @brief classes which drive on roads
    SVC_ROAD_CLASSES = (SVC_PEDESTRIAN | SVC_PASSENGER | SVC_HOV | SVC_TAXI | SVC_BUS | SVC_COACH | SVC_DELIVERY
                        | SVC_TRUCK | SVC_TRAILER | SVC_MOTORCYCLE | SVC_MOPED | SVC_BICYCLE | SVC_E_VEHICLE),
    /// @brief classes which (normally) do not drive on normal roads
    SVC_NON_ROAD = SVC_RAIL_CLASSES | SVC_SHIP
};



// ===========================================================================
// class definitions
// ===========================================================================
/**
 * @class PollutantsInterface
 * @brief Helper methods for PHEMlight-based emission computation
 */
class PollutantsInterface {

public:
    /// @brief Enumerating all emission types, including fuel
    enum EmissionType { CO2, CO, HC, FUEL, NO_X, PM_X, ELEC };

    /**
     * @struct Emissions
     * @brief Storage for collected values of all emission types
     */
    struct Emissions {
        /** @brief Constructor, intializes all members
         * @param[in] co2 initial value for CO2, defaults to 0
         * @param[in] co  initial value for CO, defaults to 0
         * @param[in] hc  initial value for HC, defaults to 0
         * @param[in] f   initial value for fuel, defaults to 0
         * @param[in] nox initial value for NOx, defaults to 0
         * @param[in] pmx initial value for PMx, defaults to 0
         * @param[in] elec initial value for electricity, defaults to 0
         */
        Emissions(double co2 = 0, double co = 0, double hc = 0, double f = 0, double nox = 0, double pmx = 0, double elec = 0);

        /** @brief Add the values of the other struct to this one, scaling the values if needed
         * @param[in] a the other emission valuess
         * @param[in] scale scaling factor, defaulting to 1 (no scaling)
         */
        void addScaled(const Emissions& a, const double scale = 1.);

        /// @brief emission types
        /// @{
        double CO2;
        double CO;
        double HC;
        double fuel;
        double NOx;
        double PMx;
        double electricity;
        /// @}
    };

    /**
    * @class Helper
    * @brief zero emission model, used as superclass for the other model helpers
    */
    class Helper {
    public:
        /** @brief Constructor, intializes the name
         * @param[in] name the name of the model (string before the '/' in the emission class attribute)
         */
        Helper(std::string name, const int baseIndex, const int defaultClass);

        /// @brief empty destructor
        virtual ~Helper() {}

        /** @brief Returns the name of the model
         * @return the name of the model (string before the '/' in the emission class attribute)
         */
        const std::string& getName() const;

        /** @brief Returns the emission class associated with the given name, aliases are possible
         * If this method is asked for the "unknown" class it should return the default
         * (possibly depending on the given vehicle class).
         * The class name is case insensitive.
         *
         * @param[in] eClass the name of the emission class (string after the '/' in the emission class attribute)
         * @param[in] vc the vehicle class to use when determining default class
         * @return the name of the model (string before the '/' in the emission class)
         */
        virtual SUMOEmissionClass getClassByName(const std::string& eClass, const SUMOVehicleClass vc);

        /** @brief Returns the complete name of the emission class including the model
         * @param[in] c the emission class
         * @return the name of the class (the complete emission class attribute)
         */
        const std::string getClassName(const SUMOEmissionClass c) const;

        /** @brief Returns whether the class denotes a silent vehicle for interfacing with the noise model.
         * By default the first class in each model is the silent class.
         * @param[in] c the emission class
         * @return whether the class denotes a silent vehicle
         */
        virtual bool isSilent(const SUMOEmissionClass c);

        /// @name Methods for Amitran interfaces
        /// @{

        /** @brief Returns the emission class described by the given parameters.
         * The base is used to determine the model to use and as default return values.
         * Default implementation returns always base.
         * @param[in] base the base class giving the model and the default
         * @param[in] vClass the vehicle class as described in the Amitran interface (Passenger, ...)
         * @param[in] fuel the fuel type as described in the Amitran interface (Gasoline, Diesel, ...)
         * @param[in] eClass the emission class as described in the Amitran interface (Euro0, ...)
         * @param[in] weight the vehicle weight in kg as described in the Amitran interface
         * @return the class described by the parameters
         */
        virtual SUMOEmissionClass getClass(const SUMOEmissionClass base, const std::string& vClass, const std::string& fuel,
                                           const std::string& eClass, const double weight) const;

        /** @brief Returns the vehicle class described by this emission class as described in the Amitran interface (Passenger, ...)
         * Default implementation returns always "Passenger".
         * @param[in] c the emission class
         * @return the name of the vehicle class
         */
        virtual std::string getAmitranVehicleClass(const SUMOEmissionClass c) const;

        /** @brief Returns the fuel type described by this emission class as described in the Amitran interface (Gasoline, Diesel, ...)
         * Default implementation returns always "Gasoline".
         * @param[in] c the emission class
         * @return the fuel type
         */
        virtual std::string getFuel(const SUMOEmissionClass c) const;

        /** @brief Returns the Euro emission class described by this emission class as described in the Amitran interface (0, ..., 6)
         * Default implementation returns always 0.
         * @param[in] c the emission class
         * @return the Euro class
         */
        virtual int getEuroClass(const SUMOEmissionClass c) const;

        /** @brief Returns a reference weight in kg described by this emission class as described in the Amitran interface
        * It might return -1, if the weight is not important to distinguish different emission classes.
        * Default implementation returns always -1.
        * @param[in] c the emission class
        * @return a reference weight
        */
        virtual double getWeight(const SUMOEmissionClass c) const;
        /// @}

        /** @brief Returns the amount of the emitted pollutant given the vehicle type and state (in mg/s or ml/s for fuel)
         * @param[in] c The vehicle emission class
         * @param[in] e the type of emission (CO, CO2, ...)
         * @param[in] v The vehicle's current velocity
         * @param[in] a The vehicle's current acceleration
         * @param[in] slope The road's slope at vehicle's position [deg]
         * @param[in] param parameter of the emission model affecting the computation
         * @return The amount emitted by the given emission class when moving with the given velocity and acceleration [mg/s or ml/s]
         */
        virtual double compute(const SUMOEmissionClass c, const EmissionType e, const double v, const double a, const double slope) const;

        /** @brief Returns the adapted acceleration value, useful for comparing with external PHEMlight references.
         * Default implementation returns always the input accel.
         * @param[in] c the emission class
         * @param[in] v the speed value
         * @param[in] a the acceleration value
         * @param[in] slope The road's slope at vehicle's position [deg]
         * @return the modified acceleration
         */
        virtual double getModifiedAccel(const SUMOEmissionClass c, const double v, const double a, const double slope) const;

        /** @brief Add all known emission classes of this model to the given container
         * @param[in] list the vector to add to
         */
        void addAllClassesInto(std::vector<SUMOEmissionClass>& list) const;

        bool includesClass(const SUMOEmissionClass c) const;

    protected:
        /// @brief the lowest speed which allows reliable coasting calculations
        static const double ZERO_SPEED_ACCURACY;

        /// @brief the name of the model
        const std::string myName;

        /// @brief the starting index for classes of this model
        const int myBaseIndex;

        /// @brief Mapping between emission class names and integer representations
        StringBijection<SUMOEmissionClass> myEmissionClassStrings;

    private:
        /// @brief invalidate copy constructor
        Helper& operator=(const Helper&) = delete;
    };

    /// @brief the first class in each model representing a zero emission vehicle
    static const int ZERO_EMISSIONS = 0;

    /// @brief the bit to set for denoting heavy vehicles
    static const int HEAVY_BIT = 1 << 15;

    /** @brief Checks whether the string describes a known vehicle class
     * @param[in] eClass The string describing the vehicle emission class
     * @return whether it describes a valid emission class
     */
    static SUMOEmissionClass getClassByName(const std::string& eClass, const SUMOVehicleClass vc = SVC_IGNORING);

    /** @brief Checks whether the string describes a known vehicle class
     * @param[in] eClass The string describing the vehicle emission class
     * @return whether it describes a valid emission class
     */
    static const std::vector<SUMOEmissionClass> getAllClasses();

    /// @brief Get all SUMOEmissionClass in string format
    static const std::vector<std::string>& getAllClassesStr();

    /** @brief Checks whether the string describes a known vehicle class
     * @param[in] eClass The string describing the vehicle emission class
     * @return whether it describes a valid emission class
     */
    static std::string getName(const SUMOEmissionClass c);

    /// @brief return the name for the given emission type
    static std::string getPollutantName(const EmissionType e);

    /** @brief Checks whether the emission class describes a bus, truck or similar vehicle
     * @param[in] c The vehicle emission class
     * @return whether it describes a heavy vehicle
     */
    static bool isHeavy(const SUMOEmissionClass c);

    /** @brief Checks whether the emission class describes an electric or similar silent vehicle
     * @param[in] c The vehicle emission class
     * @return whether it describes a silent vehicle
     */
    static bool isSilent(const SUMOEmissionClass c);

    /** @brief Returns the emission class fittig the given parameters
     * @param[in] base The base emission class to derive from
     * @param[in] vClass The vehicle class description (like "truck")
     * @param[in] eClass The emission class description (like "Euro5")
     * @param[in] fuel The fuel type (like "Diesel")
     * @param[in] weight The weight in kg
     * @return The best fitting emission class related to the base
     */
    static SUMOEmissionClass getClass(const SUMOEmissionClass base, const std::string& vClass, const std::string& fuel, const std::string& eClass, const double weight);

    /** @brief Returns the vehicle class described by the given emission class
     * @param[in] c The vehicle emission class
     * @return The Amitran string describing the vehicle class
     */
    static std::string getAmitranVehicleClass(const SUMOEmissionClass c);

    /** @brief Returns the fuel type of the given emission class
     * @param[in] c The vehicle emission class
     * @return "Diesel", "Gasoline", "HybridDiesel", or "HybridGasoline"
     */
    static std::string getFuel(const SUMOEmissionClass c);

    /** @brief Returns the Euro norm described by the given emission class
     * @param[in] c The vehicle emission class
     * @return A value between 0 and 6 (inclusive)
     */
    static int getEuroClass(const SUMOEmissionClass c);

    /** @brief Returns a representative weight for the given emission class
     * see http://colombo-fp7.eu/deliverables/COLOMBO_D4.2_ExtendedPHEMSUMO_v1.7.pdf
     * @param[in] c The vehicle emission class
     * @return the weight in kg if it matters, 0 otherwise
     */
    static double getWeight(const SUMOEmissionClass c);

    /** @brief Returns the amount of the emitted pollutant given the vehicle type and state (in mg/s or ml/s for fuel)
     * @param[in] c The vehicle emission class
     * @param[in] e the type of emission (CO, CO2, ...)
     * @param[in] v The vehicle's current velocity
     * @param[in] a The vehicle's current acceleration
     * @param[in] slope The road's slope at vehicle's position [deg]
     * @return The amount emitted by the given vehicle class when moving with the given velocity and acceleration [mg/s]
     */
    static double compute(const SUMOEmissionClass c, const EmissionType e, const double v, const double a, const double slope);

    /** @brief Returns the amount of all emitted pollutants given the vehicle type and state (in mg/s or ml/s for fuel)
     * @param[in] c The vehicle emission class
     * @param[in] v The vehicle's current velocity
     * @param[in] a The vehicle's current acceleration
     * @param[in] slope The road's slope at vehicle's position [deg]
     * @return The amount emitted by the given vehicle class when moving with the given velocity and acceleration [mg/s]
     */
    static Emissions computeAll(const SUMOEmissionClass c, const double v, const double a, const double slope);

    /** @brief Returns the amount of emitted pollutant given the vehicle type and default values for the state (in mg)
     * @param[in] c The vehicle emission class
     * @param[in] e the type of emission (CO, CO2, ...)
     * @param[in] v The vehicle's average velocity
     * @param[in] a The vehicle's average acceleration
     * @param[in] slope The road's slope at vehicle's position [deg]
     * @param{in] tt the time the vehicle travels
     * @return The amount emitted by the given vehicle class [mg]
     */
    static double computeDefault(const SUMOEmissionClass c, const EmissionType e, const double v, const double a, const double slope, const double tt);

    /** @brief Returns the adapted acceleration value, useful for comparing with external PHEMlight references.
     * @param[in] c the emission class
     * @param[in] v the speed value
     * @param[in] a the acceleration value
     * @param[in] slope The road's slope at vehicle's position [deg]
     * @return the modified acceleration
     */
    static double getModifiedAccel(const SUMOEmissionClass c, const double v, const double a, const double slope);

private:
    /// @brief Instance of HBEFA4Helper which gets cleaned up automatically
    static HelpersHBEFA4 myHBEFA4Helper;

    /// @brief the known model helpers
    static Helper* myHelpers[];

    /// @brief get all emission classes in string format
    static std::vector<std::string> myAllClassesStr;
};
