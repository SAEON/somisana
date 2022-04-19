import { jsx as _jsx } from "react/jsx-runtime";
import { hydrateRoot } from "react-dom/client";
export default function(Page) {
    return hydrateRoot(document.getElementById("root")).render(/*#__PURE__*/ _jsx(Page, {}));
};
