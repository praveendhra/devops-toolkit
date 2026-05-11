"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const probot_1 = require("probot");
const app_1 = __importDefault(require("../src/app"));
const probot = (0, probot_1.createProbot)();
exports.default = (0, probot_1.createNodeMiddleware)(app_1.default, { probot, webhooksPath: "/api/github/webhooks" });
//# sourceMappingURL=webhooks.js.map