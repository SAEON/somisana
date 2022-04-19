import { jsx as _jsx } from "react/jsx-runtime";
import ConfigProvider from "../../modules/config/index.js";
import Counter from "../../modules/counter/index.js";
export default function() {
    return /*#__PURE__*/ _jsx(ConfigProvider, {
        children: /*#__PURE__*/ _jsx(Counter, {})
    });
};
