const mongoose = require("mongoose");
const bcrypt = require('bcryptjs');
const db = require("../config/db");

const { Schema } = mongoose;

const userSchema = new Schema({
    name: {
        type: String,
        required: [true, "Name is required"],
    },
    mobile: {
        type: String,
        required: [true, "Mobile number is required"],
        match: [
            /^[0-9]{10}$/,
            "Mobile number must be a valid 10-digit number",
        ],
        unique: true,
    },
    email: {
        type: String,
        lowercase: true,
        required: [true, "Email can't be empty"],
        match: [
            /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/,
            "Email format is not correct",
        ],
        unique: true,
    },
    password: {
        type: String,
        required: [true, "Password is required"],
    },
    height: {
        type: Number,
        required: [true, "Height is required"],
    },
    weight: {
        type: Number,
        required: [true, "Weight is required"],
    },
    bloodGroup: {
        type: String,
        required: [true, "Blood group is required"],
    },
    age: {
        type: Number,
        required: [true, "Age is required"],
    },
    allergies: {
        type: String,
        default: "", 
    },
    medicalConditions: {
        type: String,
        default: "", 
    },
    medications: {
        type: String,
        default: "", 
    },
});


userSchema.pre("save", async function (next) {
    try {
        if (!this.isModified("password")) return next();
        const salt = await bcrypt.genSalt(10);
        this.password = await bcrypt.hash(this.password, salt);
        next();
    } catch (err) {
        next(err);
    }
});


userSchema.methods.comparePassword = async function (candidatePassword) {
    try {
        return await bcrypt.compare(candidatePassword, this.password);
    } catch (error) {
        throw new Error("Password comparison failed");
    }
};

const UserModel = db.model("user", userSchema);

module.exports = UserModel;