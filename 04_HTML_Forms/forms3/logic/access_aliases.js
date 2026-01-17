// Access control alias helper for HTML forms
// Creates hidden alias elements that mirror existing controls.

(function () {
    function isCheckbox(el) {
        return el && el.tagName === 'INPUT' && el.type === 'checkbox';
    }

    function createAliasElement(target) {
        if (!target) return null;
        let alias;
        if (target.tagName === 'SELECT') {
            alias = document.createElement('select');
        } else {
            alias = document.createElement('input');
            if (isCheckbox(target)) alias.type = 'checkbox';
            else alias.type = 'text';
        }
        alias.style.display = 'none';
        return alias;
    }

    function syncValue(src, dst) {
        if (!src || !dst) return;
        if (isCheckbox(src)) {
            dst.checked = !!src.checked;
        } else {
            dst.value = src.value ?? '';
        }
    }

    function link(aliasId, targetId) {
        if (document.getElementById(aliasId)) return;
        const target = document.getElementById(targetId);
        if (!target) return;
        const alias = createAliasElement(target);
        if (!alias) return;
        alias.id = aliasId;
        target.insertAdjacentElement('afterend', alias);
        syncValue(target, alias);
        target.addEventListener('input', () => syncValue(target, alias));
        target.addEventListener('change', () => syncValue(target, alias));
        alias.addEventListener('input', () => syncValue(alias, target));
        alias.addEventListener('change', () => syncValue(alias, target));
    }

    function setValue(aliasId, value) {
        const el = document.getElementById(aliasId);
        if (!el) return;
        if (isCheckbox(el)) el.checked = !!value;
        else el.value = value ?? '';
    }

    window.AccessAliases = {
        link,
        setValue
    };
})();
