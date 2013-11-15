/*
 * Copyright 2012, 2013 Donghyuck, Son
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package architecture.ee.web.navigator;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import architecture.common.util.StringUtils;


public class MenuComponent extends MenuBase implements Serializable, Component {
    //~ Static fields/initializers =============================================
    protected static MenuComponent[] _menuComponent = new MenuComponent[0];

    //~ Instance fields ========================================================

    protected List<MenuComponent> menuComponents = Collections.synchronizedList(new ArrayList<MenuComponent>());
    protected MenuComponent parentMenu;
    private boolean last;
    private String breadCrumb;

    //~ Methods ================================================================

    public void addMenuComponent(MenuComponent menuComponent) {
        if ((menuComponent.getName() == null) || (menuComponent.getName().equals(""))) {
            menuComponent.setName(this.name + menuComponents.size());
        }

        if (!menuComponents.contains(menuComponent)) {
            menuComponents.add(menuComponent);
            menuComponent.setParent(this);
        }
    }

    public MenuComponent[] getMenuComponents() {
        return (MenuComponent[]) menuComponents.toArray(_menuComponent);
    }

    public void setMenuComponents(MenuComponent[] menuComponents) {
        for (int i = 0; i < menuComponents.length; i++) {
            MenuComponent component = menuComponents[i];
            this.menuComponents.add(component);
        }
    }

    public void setParent(MenuComponent parentMenu) {
        if (parentMenu != null) {
            // look up the parent and make sure that it has this menu as a child
            if (!parentMenu.getComponents().contains(this)) {
                parentMenu.addMenuComponent(this);
            }
        }
        this.parentMenu = parentMenu;
    }

    public MenuComponent getParent() {
        return parentMenu;
    }

    /**
     * Convenience method for Velocity templates
     * @return menuComponents as a java.util.List
     */
    public List<MenuComponent> getComponents() {
        return menuComponents;
    }

    /**
     * This method compares all attributes, except for parent and children
     *
     * @param o the object to compare to
     */
    public boolean equals(Object o) {
        if (!(o instanceof MenuComponent)) {
            return false;
        }
        MenuComponent m = (MenuComponent) o;
        // Compare using StringUtils to avoid NullPointerExceptions
        return StringUtils.equals(m.getAction(), this.action) &&
                StringUtils.equals(m.getAlign(), this.align) &&
                StringUtils.equals(m.getAltImage(), this.altImage) &&
                StringUtils.equals(m.getDescription(), this.description) &&
                StringUtils.equals(m.getForward(), this.forward) &&
                StringUtils.equals(m.getHeight(), this.height) &&
                StringUtils.equals(m.getImage(), this.image) &&
                StringUtils.equals(m.getLocation(), this.location) &&
                StringUtils.equals(m.getName(), this.name) &&
                StringUtils.equals(m.getOnclick(), this.onclick) &&
                StringUtils.equals(m.getOndblclick(), this.ondblclick) &&
                StringUtils.equals(m.getOnmouseout(), this.onmouseout) &&
                StringUtils.equals(m.getOnmouseover(), this.onmouseover) &&
                StringUtils.equals(m.getOnContextMenu(), this.onContextMenu) &&
                StringUtils.equals(m.getPage(), this.page) &&
                StringUtils.equals(m.getRoles(), this.roles) &&
                StringUtils.equals(m.getTarget(), this.target) &&
                StringUtils.equals(m.getTitle(), this.title) &&
                StringUtils.equals(m.getToolTip(), this.toolTip) &&
                StringUtils.equals(m.getWidth(), this.width) &&
                StringUtils.equals(m.getModule(), this.module);
    }

    /**
     * Get the depth of the menu
     *
     * @return Depth of menu
     */
    public int getMenuDepth() {
        return getMenuDepth(this, 0);
    }

    private int getMenuDepth(MenuComponent menu, int currentDepth) {
        int depth = currentDepth + 1;

        MenuComponent[] subMenus = menu.getMenuComponents();
        if (subMenus != null) {
            for (int a = 0; a < subMenus.length; a++) {
                int depthx = getMenuDepth(subMenus[a], currentDepth + 1);
                if (depth < depthx)
                    depth = depthx;
            }
        }

        return depth;
    }

    /**
     * Returns the last.
     *
     * @return boolean
     */
    public boolean isLast() {
        return last;
    }

    /**
     * Sets the last.
     *
     * @param last The last to set
     */
    public void setLast(boolean last) {
        this.last = last;
    }

    /**
     * Remove all children from a parent menu item
     */
    public void removeChildren() {
        for ( MenuComponent child  : this.getComponents() ){
        	 child.setParent(null);
        }
        this.getComponents().clear();
    }

    public String getBreadCrumb() {
        return breadCrumb;
    }

    /**
     * Build the breadcrumb trail leading to this menuComponent
     *
     * @param delimiter type of separator
     */
    protected void setBreadCrumb(String delimiter) {
        if (getParent() == null) {
            breadCrumb = name;
            setChildBreadCrumb(delimiter);
        } else {
            MenuComponent parent = getParent();
            breadCrumb = parent.getBreadCrumb() + delimiter + name;
            setChildBreadCrumb(delimiter);
        }
    }

    private void setChildBreadCrumb(String delimiter) {
        for( MenuComponent child : this.getComponents() ){
        	child.setBreadCrumb(delimiter);
        }
    }

    public String toString() {
        return "name: " + this.name;
    }
}
