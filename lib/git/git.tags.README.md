## **Tag Helper Summary**

### **`_gtag`** — Create/recreate and push dev tag

**Use:** Anytime you want to tag + push (initial or updates)  
**Equivalent:**

```bash
git tag -d v8.21.0-SBS-154909-tag-v1                   # delete local if exists
git push --delete origin v8.21.0-SBS-154909-tag-v1     # delete remote if exists
git tag v8.21.0-SBS-154909-tag-v1                      # create at HEAD
git push -u origin build-SBS-154909 --force-with-lease # push branch
git push origin v8.21.0-SBS-154909-tag-v1              # push tag
```

Force mode by default – deletes/recreates tag, pushes everything.

---

**Workflow:**

1. Make changes, commit
2. Run `_gtag`
3. Done (reuses same `tag-v1`, no package.json changes)
